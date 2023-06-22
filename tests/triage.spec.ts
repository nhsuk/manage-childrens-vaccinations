import { test, expect } from "@playwright/test";

const patients = {
  "Aaron Pfeffer": {
    row: 1,
    note: "",
    status: "To do",
    class: "nhsuk-tag--grey",
    consent_response: "Given by",
    type_of_consent: "Paper",
  },
  "Alaia Lakin": {
    row: 2,
    note: "",
    status: "Ready for session",
    class: "nhsuk-tag--green",
    icon: "nhsuk-icon__tick",
    consent_response: "Given by",
    type_of_consent: "Website",
  },
  "Aliza Kshlerin": {
    row: 3,
    note: "Notes from nurse",
    status: "Ready for session",
    class: "nhsuk-tag--green",
    icon: "nhsuk-icon__tick",
    consent_response: "Given by",
    type_of_consent: "Phone",
  },
  "Amalia Wiza": {
    row: 4,
    note: "",
    status: "Do not vaccinate",
    class: "nhsuk-tag--red",
    icon: "nhsuk-icon__cross",
    consent_response: "Given by",
    type_of_consent: "Website",
  },
  "Amara Klein": {
    row: 5,
    note: "Notes from nurse",
    status: "Do not vaccinate",
    class: "nhsuk-tag--red",
    icon: "nhsuk-icon__cross",
    consent_response: "Given by",
    type_of_consent: "Website",
  },
  "Amara Rodriguez": {
    row: 6,
    note: "",
    status: "Needs follow up",
    class: "nhsuk-tag--blue",
    consent_response: "Given by",
    type_of_consent: "Self consent",
  },
  "Amaya Sauer": {
    row: 7,
    note: "",
    status: "To do",
    class: "nhsuk-tag--grey",
    consent_response: "No response given",
  },
  "Annabel Morar": {
    row: 8,
    note: "",
    status: "To do",
    class: "nhsuk-tag--grey",
    consent_response: "Refused by",
    reason_for_refusal: "Personal choice",
    type_of_consent: "Website",
  },
};

test("Performing triage", async ({ page }) => {
  await page.goto("/reset");

  await page.goto("/sessions/1");
  await page.getByRole("link", { name: "Triage" }).click();

  await expect(page.locator("h1")).toContainText("Triage");

  await then_i_should_see_the_correct_breadcrumbs(page);
  await then_i_should_see_patients_with_their_triage_info(page);

  await page.getByRole("link", { name: "Aaron Pfeffer" }).click();
  await then_i_should_see_the_triage_page_for_the_patient(
    page,
    "Aaron Pfeffer"
  );
  await page.getByRole("link", { name: "Back to triage" }).click();

  await page.getByRole("link", { name: "Annabel Morar" }).click();
  await then_i_should_see_the_triage_page_for_the_patient(
    page,
    "Annabel Morar"
  );
  await page.getByRole("link", { name: "Back to triage" }).click();

  await page.getByRole("link", { name: "Amaya Sauer" }).click();
  await then_i_should_see_the_triage_page_for_the_patient(page, "Amaya Sauer");
  await page.getByRole("link", { name: "Back to triage" }).click();
});

async function then_i_should_see_the_correct_breadcrumbs(page) {
  await expect(
    page.locator(".nhsuk-breadcrumb__item:last-of-type")
  ).toContainText(
    "HPV campaign at St Andrew's Benn CofE (Voluntary Aided) Primary School"
  );
}

async function then_i_should_see_patients_with_their_triage_info(page) {
  for (let name in patients) {
    let patient = patients[name];

    await expect(
      page.locator(`#patients tr:nth-child(${patient.row}) td:first-child`),
      `Name for patient row: ${patient.row} name: ${name}`
    ).toContainText(name);

    if (patient.note) {
      await expect(
        page.locator(`#patients tr:nth-child(${patient.row}) td:nth-child(2)`),
        `Note for patient row: ${patient.row} name: ${name}`
      ).toContainText(patient.note);
    } else {
      await expect(
        page.locator(`#patients tr:nth-child(${patient.row}) td:nth-child(2)`),
        `Empty note patient row: ${patient.row} name: ${name}`
      ).toBeEmpty();
    }
    await expect(
      page.locator(`#patients tr:nth-child(${patient.row}) td:nth-child(3)`),
      `Status text for patient row: ${patient.row} name: ${name}`
    ).toContainText(patient.status);

    await expect(
      page.locator(
        `#patients tr:nth-child(${patient.row}) td:nth-child(3) div`
      ),
      `Status colour for patient row: ${patient.row} name: ${name}`
    ).toHaveClass(new RegExp(patient.class));

    if (patient.icon) {
      await expect(
        page.locator(
          `#patients tr:nth-child(${patient.row}) td:nth-child(3) div svg`
        ),
        `Status icon patient row: ${patient.row} name: ${name}`
      ).toHaveClass(new RegExp(patient.icon));
    } else {
      expect(
        await page
          .locator(
            `#patients tr:nth-child(${patient.row}) td:nth-child(3) div svg`
          )
          .count(),
        `No status icon for patient row: ${patient.row} name: ${name}`
      ).toEqual(0);
    }
  }
}

async function then_i_should_see_the_triage_page_for_the_patient(page, name) {
  let patient = patients[name];
  await expect(page.locator("h1")).toContainText(name);

  await expect(page.locator("#consent")).toContainText(
    patient["consent_response"]
  );

  if (patient["type_of_consent"]) {
    await expect(page.locator("#consent")).toContainText(
      "Type of consent " + patient["type_of_consent"]
    );
  }

  if (patient["reason_for_refusal"]) {
    await expect(page.locator("#consent")).toContainText(
      "Reason for refusal " + patient["reason_for_refusal"]
    );
  }

  // Parent relationship if other
}
