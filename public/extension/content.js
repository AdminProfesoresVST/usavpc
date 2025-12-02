// USVPC Autofill Script
// This script is designed to run on the CEAC website (https://ceac.state.gov/GenNIV/)

console.log("USVPC Autofill Extension Loaded");

// Listen for messages from the popup
chrome.runtime.onMessage.addListener(function (request, sender, sendResponse) {
    if (request.action === "autofill") {
        fillForm(request.data);
        sendResponse({ status: "success" });
    }
});

function fillForm(data) {
    console.log("Filling form with data:", data);

    // Helper to safely set value
    const setValue = (selector, value) => {
        const element = document.querySelector(selector);
        if (element) {
            element.value = value;
            // Trigger change event for React/Angular apps
            element.dispatchEvent(new Event('change', { bubbles: true }));
            element.dispatchEvent(new Event('input', { bubbles: true }));
        } else {
            console.warn(`Element not found: ${selector}`);
        }
    };

    // --- DS-160 Mapping (Example Fields) ---

    // Personal Information
    if (data.surname) setValue("input[id*='ctl00_SiteContentPlaceHolder_FormView1_tbxSurname']", data.surname);
    if (data.givenName) setValue("input[id*='ctl00_SiteContentPlaceHolder_FormView1_tbxGivenName']", data.givenName);
    if (data.fullNameNative) setValue("input[id*='ctl00_SiteContentPlaceHolder_FormView1_tbxFullNameNative']", data.fullNameNative);

    // Passport Information
    if (data.passportNumber) setValue("input[id*='ctl00_SiteContentPlaceHolder_FormView1_tbxPassportNumber']", data.passportNumber);

    // Travel Information
    // ... add more mappings as needed

    alert("USVPC: Form fields populated!");
}
