const visitorCount = document.getElementById("visitor-count");

fetch("https://bzn9vys03j.execute-api.eu-west-2.amazonaws.com/visitors")
    .then(response => response.text())
    .then(count => {
        visitorCount.textContent = count;
    })
    .catch(error => {
        console.error("Error fetching visitor count:", error);
        visitorCount.textContent = "Unavailable";
    });