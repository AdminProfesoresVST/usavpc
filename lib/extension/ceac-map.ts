// CEAC Form Mapping Definition
// Maps internal DS-160 Payload fields to CEAC DOM Selectors and Value Transformations

export const CEAC_MAP = {
    // 1. Personal Information
    personal: {
        surnames: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_SURNAME',
            type: 'text'
        },
        given_names: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_GIVEN_NAME',
            type: 'text'
        },
        full_name_native: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxAPP_FULL_NAME_NATIVE',
            type: 'text'
        },
        marital_status: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_ddlMARITAL_STATUS',
            type: 'select',
            valueMap: {
                'SINGLE': 'S',
                'MARRIED': 'M',
                'DIVORCED': 'D',
                'WIDOWED': 'W'
            }
        }
    },

    // 2. Travel Information
    travel: {
        purpose_code: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_ddlPURPOSE_OF_TRIP',
            type: 'select',
            valueMap: {
                'B1': 'B',
                'B2': 'B',
                'B1_B2': 'B'
            }
        },
        paying_entity: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_ddlPAYING_ENTITY',
            type: 'select',
            valueMap: {
                'SELF': 'S',
                'OTHER_PERSON': 'O',
                'ORGANIZATION': 'C'
            }
        }
    },

    // 3. Work/Education
    work: {
        current_employer: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxEMPLOYER_NAME',
            type: 'text'
        },
        job_title: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxJOB_TITLE',
            type: 'text',
            sourceField: 'job_title_translated_en' // Use the AI translated version
        },
        duties: {
            selector: '#ctl00_SiteContentPlaceHolder_FormView1_tbxDUTIES',
            type: 'textarea',
            sourceField: 'duties_formatted_en' // Use the AI translated version
        }
    }
};

// Helper function to generate the automation script (for the extension to inject)
export function generateAutomationScript(payload: any) {
    return `
        (function() {
            console.log("Starting USVPC Automation...");
            const data = ${JSON.stringify(payload)};
            const map = ${JSON.stringify(CEAC_MAP)};

            function setVal(selector, value) {
                const el = document.querySelector(selector);
                if (el) {
                    el.value = value;
                    el.dispatchEvent(new Event('change', { bubbles: true }));
                }
            }

            // Example: Personal Info
            if (data.ds160_data.personal) {
                setVal(map.personal.surnames.selector, data.ds160_data.personal.surnames);
                setVal(map.personal.given_names.selector, data.ds160_data.personal.given_names);
                // ... Map logic would iterate here
            }
            
            console.log("Automation Complete.");
        })();
    `;
}
