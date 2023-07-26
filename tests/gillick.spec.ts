import { test, expect } from "@playwright/test";

let p = null;

test("Records gillick consent", async ({ page }) => {
  p = page;
  await given_the_app_is_setup();

  // Gillick competence passed
  await when_i_go_to_the_vaccinations_page();
  await then_i_see_the_patient_that_needs_consent();

  await when_i_click_on_the_patient();
  await then_i_see_the_no_consent_banner();

  await when_i_click_yes_gillick();
  await and_i_click_continue();
  await then_i_see_the_assessing_gillick_page();

  await when_i_click_give_your_assessment();
  await then_i_see_the_gillick_competence_page();

  await when_i_click_yes_they_are_gillick_competent();
  await and_i_give_details();
  await and_i_click_continue();
  await then_i_see_the_do_they_agree_page();

  await when_i_click_yes();
  await and_i_click_continue();
  await then_i_see_the_health_questions_page();

  await when_i_answer_the_health_questions();
  await and_i_triage_the_patient();
  await and_i_click_continue();
  await then_i_see_the_check_answers_page();
  await and_it_contains_gillick_assessment_details();

  await when_i_click_confirm();
  await then_i_see_the_vaccination_show_page();

  // Not Gillick competent
  await when_i_go_to_the_vaccinations_page();
  await when_i_click_on_the_second_patient();

  await when_i_click_yes_gillick();
  await and_i_click_continue();
  await when_i_click_give_your_assessment();
  await when_i_click_no_they_are_not_gillick_competent();
  await and_i_give_details();
  await and_i_click_continue();
  await then_i_see_the_vaccination_show_page_for_the_second_patient();
});

async function given_the_app_is_setup() {
  await p.goto("/reset");
}

async function when_i_go_to_the_vaccinations_page() {
  await p.goto("/sessions/1/vaccinations");
}

async function then_i_see_the_patient_that_needs_consent() {
  await expect(p.getByRole("link", { name: "Alexandra Sipes" })).toBeVisible();
}

async function when_i_click_on_the_patient() {
  await p.click("text=Alexandra Sipes");
}

async function then_i_see_the_no_consent_banner() {
  await expect(p.locator(".app-consent-banner")).toContainText(
    "No-one responded to our requests for consent",
  );
}

async function when_i_click_yes_gillick() {
  await p.click("text=Yes, I am assessing Gillick competence");
}

async function and_i_click_continue() {
  await p.click("text=Continue");
}

async function then_i_see_the_assessing_gillick_page() {
  await expect(p.locator("h1")).toContainText("Gillick competence");
}

async function when_i_click_give_your_assessment() {
  await p.click("text=Give your assessment");
}

async function then_i_see_the_gillick_competence_page() {
  await expect(p.locator("h1")).toContainText("Are they Gillick competent?");
}

async function when_i_click_yes_they_are_gillick_competent() {
  await p.click("text=Yes, they are Gillick competent");
}

async function and_i_give_details() {
  await p.fill(
    '[name="patient_session[gillick_competence_notes]"]',
    "They were very mature",
  );
}

async function then_i_see_the_do_they_agree_page() {
  await expect(p.locator("h1")).toContainText("Do they agree");
}

async function when_i_click_yes() {
  await p.getByRole("radio", { name: "Yes, they agree" }).click();
}

async function then_i_see_the_health_questions_page() {
  await expect(p.locator("h1")).toContainText("Health questions");
}

async function when_i_answer_the_health_questions() {
  const radio = (n: number) =>
    `input[name="consent_response[question_${n}][response]"][value="no"]`;

  await p.click(radio(0));
  await p.click(radio(1));
  await p.click(radio(2));
  await p.click(radio(3));
}

async function then_i_see_the_check_answers_page() {
  await expect(p.locator("h1")).toContainText("Check and confirm answers");
}

async function when_i_click_confirm() {
  await p.getByRole("button", { name: "Confirm" }).click();
}

async function then_i_see_the_vaccination_show_page() {
  await expect(p.locator("h1")).toContainText("Alexandra Sipes");
}

async function and_it_contains_gillick_assessment_details() {
  await expect(
    p.getByRole("heading", { name: "Gillick competence" }),
  ).toBeVisible();
}

async function when_i_click_on_the_second_patient() {
  await p.click("text=Mariano Kuhic");
}

async function when_i_click_no_they_are_not_gillick_competent() {
  await p.click("text=No");
}

async function then_i_see_the_vaccination_show_page_for_the_second_patient() {
  await expect(p.locator("h1")).toContainText("Mariano Kuhic");
}

async function and_i_triage_the_patient() {
  await p.fill('[name="consent_response[triage][notes]"]', "Some notes");
  await p.getByRole("radio", { name: "Ready to vaccinate" }).click();
}
