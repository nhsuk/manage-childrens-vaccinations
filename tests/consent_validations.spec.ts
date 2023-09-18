import { test, expect, Page } from "@playwright/test";
import { signInTestUser } from "./shared/sign_in";

let p: Page;

test("Consent validations", async ({ page }) => {
  p = page;
  await given_the_app_is_setup();
  await and_i_am_signed_in();

  // Who are you getting consent from validations
  await given_i_am_on_the_who_am_i_contacting_for_consent_page();
  await when_i_continue_without_entering_anything();
  await then_i_see_the_who_i_am_contacting_validation_errors();

  await given_i_select_other_relationship();
  await when_i_continue_without_entering_anything();
  await then_i_see_the_other_relationship_validation_errors();

  // Consent response validations
  await given_i_move_on_to_the_consent_response_page();
  // TODO: There is currently a bug where submitting this returns an empty response.
  // await when_i_continue_without_entering_anything();
  // await then_i_see_the_consent_response_form_validation_errors();

  // Triage details validations
  await given_i_move_on_to_the_triage_details_page();
  await when_i_continue_without_entering_anything();
  await then_i_see_the_triage_details_validation_errors();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function and_i_am_signed_in() {
  await p.goto("/users/sign_in");
  await signInTestUser(p);
}

async function given_i_am_on_the_who_am_i_contacting_for_consent_page() {
  await p.goto("/sessions/1/triage");
  await p.getByRole("tab", { name: "Get consent" }).click();
  await p.getByRole("link", { name: "Alexandra Sipes" }).click();
  await p.getByRole("button", { name: "Get consent" }).click();
}

async function when_i_continue_without_entering_anything() {
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_consent_response_form_validation_errors() {
  await expect(
    p.getByRole("alert").getByText("Choose yes or no"),
  ).toBeVisible();
}

async function then_i_see_the_who_i_am_contacting_validation_errors() {
  const alert = p.getByRole("alert");
  await expect(alert).toBeVisible();
  await expect(alert).toContainText("Enter a name");
  await expect(alert).toContainText("Enter a phone number");
  await expect(alert).toContainText("Choose a relationship");
}

async function given_i_select_other_relationship() {
  await p.getByRole("radio", { name: "Other" }).click();
}

async function then_i_see_the_other_relationship_validation_errors() {
  await expect(
    p.getByRole("alert").getByText("Enter a relationship"),
  ).toBeVisible();
}

async function given_i_move_on_to_the_consent_response_page() {
  await p.fill('[name="consent[parent_name]"]', "Carl Sipes");
  await p.fill('[name="consent[parent_phone]"]', "07700900000");
  await p.getByRole("radio", { name: "Dad" }).click();
  await p.getByRole("button", { name: "Continue" }).click();
}

async function given_i_move_on_to_the_triage_details_page() {
  await p.getByRole("radio", { name: "Yes, they agree" }).click();
  await p.getByRole("button", { name: "Continue" }).click();
}

async function then_i_see_the_triage_details_validation_errors() {
  await expect(p.getByRole("alert").getByText("Choose a status")).toBeVisible();
}
