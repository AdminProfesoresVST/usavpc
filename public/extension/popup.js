document.getElementById('fillBtn').addEventListener('click', () => {
    const jsonStr = document.getElementById('jsonData').value;
    try {
        const data = JSON.parse(jsonStr);

        chrome.tabs.query({ active: true, currentWindow: true }, function (tabs) {
            chrome.tabs.sendMessage(tabs[0].id, { action: "autofill", data: data }, function (response) {
                console.log(response);
            });
        });
    } catch (e) {
        alert("Invalid JSON data!");
    }
});
