import { test, expect, Page } from "@playwright/test";
import { signInTestUser, fixtures, formatDate } from "./shared";

let p: Page;

test("Session create", async ({ page }) => {
  p = page;

  await given_the_app_is_setup();
  await and_i_am_signed_in();

  await when_i_go_to_the_sessions_list();
  await and_i_click_on_the_add_session_button();
  await then_i_see_the_location_page();

  await when_i_submit_without_choosing_a_location();
  await then_i_see_the_location_page_with_errors();

  await when_i_choose_my_location();
  await then_i_see_the_when_page();

  await when_i_submit_without_choosing_when();
  await then_i_see_the_when_page_with_errors();

  await when_i_choose_when();
  await then_i_see_the_cohort_page();

  await when_i_uncheck_all_patients_and_submit();
  await then_i_see_the_cohort_page_with_errors();

  await when_i_submit_with_all_patients_checked();
  await then_i_see_the_timeline_page();

  await when_i_choose_my_timeline();
  await then_i_see_the_confirm_details_page();

  await when_i_click_on_the_confirm_button();
  await then_i_see_the_session_details_page();

  await when_i_click_the_view_session_link();
  await then_i_see_the_view_session_page();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function and_i_am_signed_in() {
  await signInTestUser(p);
}

async function when_i_go_to_the_sessions_list() {
  await p.goto("/sessions");
}

async function and_i_click_on_the_add_session_button() {
  await p.click("text=Add a new session");
}

async function then_i_see_the_location_page() {
  await expect(
    p.getByRole("heading", {
      name: "Which school is it at?",
    }),
  ).toBeVisible();
}

async function when_i_submit_without_choosing_a_location() {
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_location_page_with_errors() {
  await expect(p.getByRole("alert")).toContainText("Choose a school");
}

async function when_i_choose_my_location() {
  await p.click("text=" + fixtures.schoolName);
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_when_page() {
  await expect(
    p.getByRole("heading", {
      name: "When is the session?",
    }),
  ).toBeVisible();
}

async function when_i_submit_without_choosing_when() {
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_when_page_with_errors() {
  await expect(p.getByRole("alert")).toContainText("Enter a date");
  await expect(p.getByRole("alert")).toContainText("Select a time of day");
}

async function when_i_choose_when() {
  const date = new Date();

  await p.getByLabel("Day", { exact: true }).fill(date.getDate().toString());
  await p.getByLabel("Month").fill((date.getMonth() + 1).toString());
  await p.getByLabel("Year").fill(date.getFullYear().toString());

  await p.getByLabel("Afternoon").click();

  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_cohort_page() {
  await expect(
    p.getByRole("heading", {
      name: "Choose cohort for this session",
    }),
  ).toBeVisible();
}

async function when_i_uncheck_all_patients_and_submit() {
  // Un-check each checkbox
  const patientCheckboxes = p.locator("input[type=checkbox]");
  const count = await patientCheckboxes.count();
  for (let i = 0; i < count; i++) {
    await patientCheckboxes.nth(i).uncheck();
  }

  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_cohort_page_with_errors() {
  await expect(p.getByRole("alert")).toContainText(
    "You must choose a cohort to continue",
  );
}

async function when_i_submit_with_all_patients_checked() {
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_confirm_details_page() {
  await expect(
    p.getByRole("heading", { name: "Check and confirm details" }),
  ).toBeVisible();

  await expect(p.locator(".nhsuk-card")).toHaveText(
    new RegExp("School" + fixtures.schoolName),
  );

  await expect(p.locator(".nhsuk-card")).toHaveText(
    new RegExp("Vaccine" + "HPV"),
  );

  await expect(p.locator(".nhsuk-card")).toHaveText(
    new RegExp("Time" + "Afternoon"),
  );

  await expect(p.locator(".nhsuk-card")).toHaveText(
    new RegExp("Cohort" + "5 children"),
  );
}

async function when_i_click_on_the_confirm_button() {
  await p.getByRole("button", { name: "Confirm" }).click();
}

async function then_i_see_the_session_details_page() {
  // TODO: Test for the session; page properly
  await expect(
    p.getByRole("heading", { name: "Check consent responses" }),
  ).toBeVisible();
}

async function then_i_see_the_timeline_page() {
  await expect(
    p.getByRole("heading", {
      name: "What’s the timeline for consent requests?",
    }),
  ).toBeVisible();
}

async function when_i_choose_my_timeline() {
  await p.getByRole("radio", { name: "14 days before the session" }).click();
  await p
    .getByRole("radio", { name: "7 days after the first consent request" })
    .click();
  await p
    .getByRole("radio", {
      name: "Allow responses until the day of the session",
    })
    .click();
  await p.getByRole("button", { name: "Continue" }).click();
}

async function when_i_click_the_view_session_link() {
  await p.getByRole("link", { name: "View session" }).click();
}

async function then_i_see_the_view_session_page() {
  await expect(
    p.getByRole("heading", { name: "Session details" }),
  ).toBeVisible();
}
