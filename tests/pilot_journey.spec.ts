import { test, expect, Page } from "@playwright/test";
import { signInTestUser, fixtures, formatDate } from "./shared";

const fs = require("node:fs/promises");
const path = require("node:path");

let p: Page;
let download;
let sessionDate;
let children;
let csv;

test("Pilot journey", async ({ page }) => {
  p = page;
  await given_the_app_is_setup();
  await and_i_am_signed_in();

  await when_i_close_the_registration_for_the_pilot();
  await then_i_see_that_registrations_are_closed();

  await when_i_download_the_list_of_parents_interested_in_the_pilot();
  await then_i_see_the_list_of_parents_who_have_registered();

  await when_i_edit_and_upload_the_cohort_list();
  await then_i_see_that_the_cohort_has_been_uploaded();

  await when_i_create_a_new_session();
  await and_select_the_children_for_the_cohort();
  await and_enter_and_confirm_the_session_details();
  await then_i_see_the_session_page();

  await when_i_look_at_children_that_need_consent_responses();
  await then_i_see_the_children_from_the_cohort();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function and_i_am_signed_in() {
  await signInTestUser(
    p,
    "nurse.florence@example.com",
    "nurse.florence@example.com",
  );
}

async function when_i_close_the_registration_for_the_pilot() {
  await p.goto("/dashboard");
  await p.click("text=Manage pilot");
  await p.click("text=See who’s interested in the pilot");
  await p.click("text=Close pilot to new participants at this school");
  await p.click("text=Yes, close the pilot to new participants");
}

async function then_i_see_that_registrations_are_closed() {
  await expect(p.locator(".nhsuk-notification-banner__content")).toContainText(
    "Pilot is now closed to new participants",
  );
}

async function when_i_download_the_list_of_parents_interested_in_the_pilot() {
  await p.goto("/dashboard");
  await p.click("text=Manage pilot");
  await p.click("text=See who’s interested in the pilot");
  [download] = await Promise.all([
    p.waitForEvent("download"),
    p
      .getByRole("link", {
        name: "Download data for registered parents (CSV)",
      })
      .click(),
  ]);
}

async function then_i_see_the_list_of_parents_who_have_registered() {
  const downloadPath = await download.path();

  csv = await fs.readFile(downloadPath, "utf-8");
  expect(csv).toContain("Quinn Beahan");
}

async function when_i_edit_and_upload_the_cohort_list() {
  const lines = csv.split("\n");
  const newCsv = lines.slice(0, 4).join("\n");
  const tmpCohortFile = path.resolve(__dirname, "../tmp/edited_cohort.csv");
  await fs.writeFile(tmpCohortFile, newCsv);

  await p.goto("/dashboard");
  await p.click("text=Manage pilot");
  await p.click("text=Upload the cohort list");
  await p.setInputFiles('input[type="file"]', tmpCohortFile);
  await p.getByRole("button", { name: "Upload the cohort list" }).click();
}

async function then_i_see_that_the_cohort_has_been_uploaded() {
  await expect(p.getByText("3 children have been added")).toBeVisible();
}

async function when_i_create_a_new_session() {
  await p.goto("/dashboard");
  await p.click("text=School session");
  await p.getByRole("button", { name: "Add a new session" }).click();

  // Choosing a school
  await p.click("text=" + fixtures.pilotSchoolName);
  await p.getByRole("button", { name: "Continue" }).click();

  // Choosing a date 30 days from today
  sessionDate = new Date();
  formatDate(sessionDate);
  sessionDate.setDate(sessionDate.getDate() + 30);
  formatDate(sessionDate);

  await p
    .getByLabel("Day", { exact: true })
    .fill(sessionDate.getDate().toString());
  await p.getByLabel("Month").fill((sessionDate.getMonth() + 1).toString());
  await p.getByLabel("Year").fill(sessionDate.getFullYear().toString());
  await p.getByLabel("Afternoon").click();
  await p.getByRole("button", { name: "Continue" }).click();
}

async function and_select_the_children_for_the_cohort() {
  // Clear all the checkboxes. Replace this with a click of a "clear all" button
  await p.locator("input[type=checkbox]").nth(0).click();

  // Check the first three children
  await p
    .locator("tr", {
      has: p.locator("td", {
        hasText: fixtures.registeredChildren[0].fullName,
      }),
    })
    .locator("input[type=checkbox]")
    .click();
  await p
    .locator("tr", {
      has: p.locator("td", {
        hasText: fixtures.registeredChildren[1].fullName,
      }),
    })
    .locator("input[type=checkbox]")
    .click();
  await p
    .locator("tr", {
      has: p.locator("td", {
        hasText: fixtures.registeredChildren[2].fullName,
      }),
    })
    .locator("input[type=checkbox]")
    .click();

  await p.getByRole("button", { name: "Continue" }).click();
}

async function and_enter_and_confirm_the_session_details() {
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

  await p.getByRole("button", { name: "Confirm" }).click();
}

async function then_i_see_the_session_page() {
  await expect(
    p.getByRole("heading", {
      name: fixtures.pilotSchoolName,
    }),
  ).toBeVisible();

  await expect(p.getByText(formatDate(sessionDate))).toBeVisible();
  await expect(p.getByText("0 children with consent given")).toBeVisible();
  await expect(p.getByText("0 children with consent refused")).toBeVisible();
  await expect(p.getByText("3 children without a response")).toBeVisible();
  await expect(
    p.getByText("0 responses need matching with a parent record"),
  ).toBeVisible();
  await expect(p.getByText("0 children needing triage")).toBeVisible();
  await expect(p.getByText("0 children ready to vaccinate")).toBeVisible();
}

async function when_i_look_at_children_that_need_consent_responses() {
  await p.click("text=Check consent responses");
  await p.click("text=No response");
}

async function then_i_see_the_children_from_the_cohort() {
  await expect(
    p.locator(".nhsuk-table__body .nhsuk-table__row", {
      hasText: fixtures.registeredChildren[0].fullName,
    }),
  ).toBeVisible();
  await expect(
    p.locator(".nhsuk-table__body .nhsuk-table__row", {
      hasText: fixtures.registeredChildren[1].fullName,
    }),
  ).toBeVisible();
  await expect(
    p.locator(".nhsuk-table__body .nhsuk-table__row", {
      hasText: fixtures.registeredChildren[2].fullName,
    }),
  ).toBeVisible();
  await expect(p.locator(".nhsuk-table__body .nhsuk-table__row")).toHaveCount(
    3,
  );
}
