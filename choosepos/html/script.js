document.addEventListener("DOMContentLoaded", () => {
    const app = document.getElementById("app");
    const resourceName = 'choosepos';

    const cards = document.querySelectorAll(".location-card");
    const timeEl = document.getElementById("time-left");
    const voteMsg = document.getElementById("vote-message");

    const voteCounters = {
        camp: document.getElementById("votes-camp"),
        merry: document.getElementById("votes-merry"),
        palmer: document.getElementById("votes-palmer"),
        avion: document.getElementById("votes-avion"),
        roxwood: document.getElementById("votes-roxwood"),
        labs: document.getElementById("votes-labs"),
        biker: document.getElementById("votes-biker"),
        kortz: document.getElementById("votes-kortz"),
        naval: document.getElementById("votes-naval"),
        manoir: document.getElementById("votes-manoir"),
        neil: document.getElementById("votes-neil"),
        casse: document.getElementById("votes-casse"),
        yacht: document.getElementById("votes-yacht"),
        usine: document.getElementById("votes-usine"),
        scirie: document.getElementById("votes-scirie"),
        sous: document.getElementById("votes-sous"),
        bell: document.getElementById("votes-bell"),
        scarface: document.getElementById("votes-scarface"),
    };

    let countdownInterval = null;
    let hasVoted = false;

    window.addEventListener("message", (event) => {
        const item = event.data;

        if (item.action === "openUI") {
            resetUI();
            app.style.display = "flex";
            startCountdown(item.time || 15);
            updateVotes(item.votes);
        }

        if (item.action === "updateVotes") {
            updateVotes(item.votes);
        }

        if (item.action === "closeUI") {
            closeUI();
        }

        if (item.action === "showCooldown") {
            const cdHud = document.getElementById('cooldown-hud');
            const cdSeconds = document.getElementById('cooldown-seconds');
            if (cdHud && cdSeconds) {
                cdSeconds.textContent = item.time;
                cdHud.style.display = 'flex';
            }
        }

        if (item.action === "updateCooldown") {
            const cdSecondsUpdate = document.getElementById('cooldown-seconds');
            if (cdSecondsUpdate) {
                cdSecondsUpdate.textContent = item.time;
            }
        }

        if (item.action === "hideCooldown") {
            const cdHudHide = document.getElementById('cooldown-hud');
            if (cdHudHide) {
                cdHudHide.style.display = 'none';
            }
        }
    });

    cards.forEach(card => {
        card.addEventListener("click", () => {
            if (hasVoted) return;

            const choice = card.getAttribute("data-choice");
            if (!choice) return;

            hasVoted = true;

            card.classList.add("selected");
            cards.forEach(c => {
                if (c !== card) c.classList.add("disabled");
            });

            voteMsg.classList.add("visible");

            fetch(`https://${resourceName}/sendVote`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ choice: choice })
            });
        });
    });

    const refuseBtn = document.getElementById("refuse-button");
    if (refuseBtn) {
        refuseBtn.addEventListener("click", () => {
            fetch(`https://${resourceName}/refuseVote`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        });
    }

    function updateVotes(votesObj) {
        if (!votesObj) return;
        if (voteCounters.camp) voteCounters.camp.textContent = votesObj.camp || 0;
        if (voteCounters.merry) voteCounters.merry.textContent = votesObj.merry || 0;
        if (voteCounters.palmer) voteCounters.palmer.textContent = votesObj.palmer || 0;
        if (voteCounters.avion) voteCounters.avion.textContent = votesObj.avion || 0;
        if (voteCounters.roxwood) voteCounters.roxwood.textContent = votesObj.roxwood || 0;
        if (voteCounters.labs) voteCounters.labs.textContent = votesObj.labs || 0;
        if (voteCounters.biker) voteCounters.biker.textContent = votesObj.biker || 0;
        if (voteCounters.kortz) voteCounters.kortz.textContent = votesObj.kortz || 0;
        if (voteCounters.naval) voteCounters.naval.textContent = votesObj.naval || 0;
        if (voteCounters.manoir) voteCounters.manoir.textContent = votesObj.manoir || 0;
        if (voteCounters.neil) voteCounters.neil.textContent = votesObj.neil || 0;
        if (voteCounters.casse) voteCounters.casse.textContent = votesObj.casse || 0;
        if (voteCounters.yacht) voteCounters.yacht.textContent = votesObj.yacht || 0;
        if (voteCounters.usine) voteCounters.usine.textContent = votesObj.usine || 0;
        if (voteCounters.scirie) voteCounters.scirie.textContent = votesObj.scirie || 0;
        if (voteCounters.sous) voteCounters.sous.textContent = votesObj.sous || 0;
        if (voteCounters.bell) voteCounters.bell.textContent = votesObj.bell || 0;
        if (voteCounters.scarface) voteCounters.scarface.textContent = votesObj.scarface || 0;
    }

    function startCountdown(seconds) {
        if (countdownInterval) clearInterval(countdownInterval);

        let timeLeft = seconds;
        timeEl.textContent = timeLeft;

        countdownInterval = setInterval(() => {
            timeLeft--;
            if (timeLeft <= 0) {
                clearInterval(countdownInterval);
                timeEl.textContent = "0";
            } else {
                timeEl.textContent = timeLeft;
            }
        }, 1000);
    }

    function resetUI() {
        hasVoted = false;
        voteMsg.classList.remove("visible");
        cards.forEach(c => {
            c.classList.remove("selected", "disabled");
        });
        if (countdownInterval) clearInterval(countdownInterval);
    }

    function closeUI() {
        app.style.display = "none";
        resetUI();
    }


    // ══════════════════════════════════════════════════════════
    //  HUD ÉQUIPES — barre compacte haut centre
    // ══════════════════════════════════════════════════════════

    const teamHud     = document.getElementById('team-hud');
    const hudMapName  = document.getElementById('hud-map-name');
    const hudCountInt = document.getElementById('hud-count-int');
    const hudCountExt = document.getElementById('hud-count-ext');

    // aliveInt / aliveExt : nombre de vivants dans chaque équipe
    let hudAliveInt = 0;
    let hudAliveExt = 0;

    function setHudCount(el, value, oldValue) {
        if (!el) return;
        el.textContent = value;
        if (value !== oldValue) {
            el.classList.remove('bump');
            void el.offsetWidth; // reflow pour relancer l'animation
            el.classList.add('bump');
            setTimeout(() => el.classList.remove('bump'), 350);
        }
    }

    window.addEventListener("message", (event) => {
        const item = event.data;

        if (item.action === "showHud") {
            const intPlayers = (item.players && item.players.interieur) ? item.players.interieur.length : 0;
            const extPlayers = (item.players && item.players.exterieur) ? item.players.exterieur.length : 0;
            hudAliveInt = intPlayers;
            hudAliveExt = extPlayers;
            if (hudMapName)  hudMapName.textContent  = item.map || '';
            if (hudCountInt) hudCountInt.textContent = hudAliveInt;
            if (hudCountExt) hudCountExt.textContent = hudAliveExt;
            if (teamHud) teamHud.style.display = 'block';
        }

        if (item.action === "updateHudPlayers") {
            const intPlayers = (item.players && item.players.interieur) ? item.players.interieur.length : hudAliveInt;
            const extPlayers = (item.players && item.players.exterieur) ? item.players.exterieur.length : hudAliveExt;
            setHudCount(hudCountInt, intPlayers, hudAliveInt);
            setHudCount(hudCountExt, extPlayers, hudAliveExt);
            hudAliveInt = intPlayers;
            hudAliveExt = extPlayers;
            if (item.map && hudMapName) hudMapName.textContent = item.map;
        }

        if (item.action === "hudPlayerDead") {
            if (item.slot === "interieur" && hudAliveInt > 0) {
                const newVal = hudAliveInt - 1;
                setHudCount(hudCountInt, newVal, hudAliveInt);
                hudAliveInt = newVal;
            } else if (item.slot === "exterieur" && hudAliveExt > 0) {
                const newVal = hudAliveExt - 1;
                setHudCount(hudCountExt, newVal, hudAliveExt);
                hudAliveExt = newVal;
            }
        }

        if (item.action === "hudResetDead") {
            const intPlayers = (item.players && item.players.interieur) ? item.players.interieur.length : 0;
            const extPlayers = (item.players && item.players.exterieur) ? item.players.exterieur.length : 0;
            hudAliveInt = intPlayers;
            hudAliveExt = extPlayers;
            if (hudCountInt) hudCountInt.textContent = hudAliveInt;
            if (hudCountExt) hudCountExt.textContent = hudAliveExt;
            if (item.map && hudMapName) hudMapName.textContent = item.map;
        }

        if (item.action === "hideHud") {
            if (teamHud) teamHud.style.display = 'none';
        }
    });

});