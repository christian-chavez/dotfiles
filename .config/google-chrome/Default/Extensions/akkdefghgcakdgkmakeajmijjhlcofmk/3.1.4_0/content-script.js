class PlayerStateMachine {
    constructor(showControls, hideControls, settings) {
        if (settings.invertTrigger) {
            this.state = "shownInverted";
        }
        else {
            this.state = "shown";
        }

        const standartDefinitions = {
            hidden: {
                actions: {
                    onEnter: hideControls
                },
                transitions: {
                    fullscreenEntered: {
                        target: "hiddenFullscreen",
                    },
                    mouseTriggerZoneExited: {
                        target: "shown",
                        guard() {
                            return !settings.onlyFullscreen;
                        },
                    },
                    hotkey: {
                        target: "shown",
                    },
                },
            },
            shown: {
                actions: {
                    onEnter: showControls
                },
                transitions: {
                    fullscreenEntered: {
                        target: "shownFullscreen",
                    },
                    mouseTriggerZoneEntered: {
                        target: "hidden",
                        guard() {
                            return !settings.onlyFullscreen;
                        },
                    },
                    hotkey: {
                        target: "hidden",
                    },
                },
            },
            hiddenFullscreen: {
                actions: {
                    onEnter: hideControls
                },
                transitions: {
                    fullscreenExited: {
                        target: "shown",
                    },
                    mouseTriggerZoneExited: {
                        target: "shownFullscreen",
                    },
                    hotkey: {
                        target: "shownFullscreen",
                    },
                },
            },
            shownFullscreen: {
                actions: {
                    onEnter: showControls
                },
                transitions: {
                    fullscreenExited: {
                        target: "shown",
                    },
                    mouseTriggerZoneEntered: {
                        target: "hiddenFullscreen",
                    },
                    hotkey: {
                        target: "hiddenFullscreen",
                    },
                },
            },
        };

        const invertedDefinitions = {
            hiddenInverted: {
                actions: {
                    onEnter: hideControls
                },
                transitions: {
                    fullscreenEntered: {
                        target: "hiddenFullscreenInverted",
                    },
                    mouseTriggerZoneEntered: {
                        target: "shownInverted",
                    },
                    mouseTriggerZoneExited: {
                        target: "shownInverted",
                    },
                    hotkey: {
                        target: "shownInverted",
                    },
                },
            },
            shownInverted: {
                actions: {
                    onEnter: showControls
                },
                transitions: {
                    fullscreenEntered: {
                        target: "hiddenFullscreenInverted",
                    },
                    hotkey: {
                        target: "hiddenInverted",
                    },
                },
            },
            hiddenFullscreenInverted: {
                actions: {
                    onEnter: hideControls
                },
                transitions: {
                    fullscreenExited: {
                        target: "shownInverted",
                    },
                    mouseTriggerZoneEntered: {
                        target: "shownFullscreenInverted",
                    },
                    hotkey: {
                        target: "shownFullscreenInverted",
                    },
                },
            },
            shownFullscreenInverted: {
                actions: {
                    onEnter: showControls
                },
                transitions: {
                    fullscreenExited: {
                        target: "shownInverted",
                    },
                    mouseTriggerZoneExited: {
                        target: "hiddenFullscreenInverted",
                    },
                    hotkey: {
                        target: "hiddenFullscreenInverted",
                    },
                },
            },
        };

        // switch from/to the inverted state when the "invertTrigger" setting changes
        for (let state in invertedDefinitions) {
            invertedDefinitions[state].transitions["settingsChanged"] = {
                target: state.substring(0, state.length - "Inverted".length),
                guard() {
                    return settings.invertTrigger;
                }
            };
        }

        for (let state in standartDefinitions) {
            standartDefinitions[state].transitions["settingsChanged"] = {
                target: state + "Inverted",
                guard() {
                    return !settings.invertTrigger;
                }
            };
        }

        this.stateDefinitions = {
            ...standartDefinitions,
            ...invertedDefinitions
        };
    }

    send(event) {
        const currentStateDefinition = this.stateDefinitions[this.state];
        const destinationTransition = currentStateDefinition.transitions[event];

        if (!destinationTransition) {
            return;
        }

        const destinationState = destinationTransition.target;
        const destinationStateDefinition = this.stateDefinitions[destinationState];

        if (destinationTransition.guard && destinationTransition.guard()) {
            return;
        }

        destinationStateDefinition.actions.onEnter();

        console.log("[youtube-hide-controls] event:", event, "transitioning: ", this.state, "=>", destinationState);
        this.state = destinationState;
        return this.state;
    }
}

class Settings {
    constructor() {
        this.onChangeCallbacks = [];

        this.injectOptionButton = true;

        this.triggerTop = 0;
        this.triggerLeft = 5;
        this.triggerRight = 5;
        this.triggerBottom = 0;

        this.hotkey = null;
        this.useHotkey = false;
        this.useMouse = true;
        this.invertTrigger = false;
        this.onlyFullscreen = false;
        this.hideVideoOverlays = false;
        this.hidePlayPauseAnimation = false;

        chrome.storage.onChanged.addListener((changes) => {
            let changedSomething = false;
            for (let key in changes) {
                if (key in this && changes[key].newValue !== this[key]) {
                    this[key] = changes[key].newValue;
                    changedSomething = true;
                }
            }

            if (changedSomething) {
                this.emitOnChange();
            }
        });
    }

    migrateOldSettings(didMigrateCallback) {
        chrome.storage.local.get([
            "onlyHotkey",
        ], (result) => {
            if ("onlyHotkey" in result) {
                this.remove("onlyHotkey");

                if (result["onlyHotkey"]) {
                    this.set("useMouse", this.useMouse = false);
                    this.set("useHotkey", this.useHotkey = true);
                }
                else {
                    this.set("useMouse", this.useMouse = true);
                    this.set("useHotkey", this.useHotkey = true);
                }

            }

            if (didMigrateCallback) {
                didMigrateCallback();
            }
        });
    }

    init(initCallback) {
        this.migrateOldSettings(() => {
            chrome.storage.local.get([
                "injectOptionButton",
                "triggerTop",
                "triggerLeft",
                "triggerRight",
                "triggerBottom",
                "hotkey",
                "useHotkey",
                "useMouse",
                "invertTrigger",
                "onlyFullscreen",
                "hideVideoOverlays",
                "hidePlayPauseAnimation",
            ], (result) => {
                for (let key in result) {
                    if (key in this) {
                        this[key] = result[key];
                    }
                }

                this.emitOnChange();
                if (initCallback) {
                    initCallback();
                }
            });
        });
    }

    addOnChangeListener(callback) {
        this.onChangeCallbacks.push(callback);
    }
    emitOnChange() {
        for (let callback of this.onChangeCallbacks) {
            callback();
        }
    }

    set(key, value, callback) {
        if (value in this) {
            this[key] = value;
        }

        chrome.storage.local.set({
            [key]: value
        });

        if (callback) {
            callback();
        }
    }
    remove(key) {
        browser.storage.local.remove(key);
    }
}

// inject player script
const script = document.createElement("script");
script.setAttribute("src", chrome.runtime.getURL("player.js"));
script.addEventListener("load", function() {
    this.remove();
});
(document.head || document.documentElement).appendChild(script);

// inject styles
const style = document.createElement("link");
style.setAttribute("rel", "stylesheet");
style.setAttribute("href", chrome.runtime.getURL("player.css"));
(document.head || document.documentElement).appendChild(style);


function hideControls() {
    console.log("[youtube-hide-controls] HIDE_PLAYER!", settings);
    window.postMessage({
        "source": "YOUTUBE_HIDE_CONTROL",
        "action": "HIDE_PLAYER"
    });
}

function showControls() {
    console.log("[youtube-hide-controls] SHOW_PLAYER!", settings);
    window.postMessage({
        "source": "YOUTUBE_HIDE_CONTROL",
        "action": "SHOW_PLAYER"
    });
}

function updateClassNames() {
    window.postMessage({
        "source": "YOUTUBE_HIDE_CONTROL",
        "action": "HIDE_VIDEO_OVERLAYS",
        "value": settings.hideVideoOverlays
    });
    window.postMessage({
        "source": "YOUTUBE_HIDE_CONTROL",
        "action": "HIDE_PLAY_PAUSE_ANIMATION",
        "value": settings.hidePlayPauseAnimation
    });
}

const settings = new Settings();
const stateMachine = new PlayerStateMachine(showControls, hideControls, settings);
settings.addOnChangeListener(() => {
    stateMachine.send("settingsChanged");
    updateClassNames();
    onFullscreenChanged();
    updateInjectedOptionButton();
});
settings.init();

// handle fullscreen change
function isFullscreen() {
    if (settings.onlyFullscreen) {
        return Boolean(document.fullscreenElement);
    }
    return true;
}

function onFullscreenChanged() {
    if (isFullscreen()) {
        stateMachine.send("fullscreenEntered");
    }
    else {
        stateMachine.send("fullscreenExited");
    }
}

document.addEventListener("fullscreenchange", onFullscreenChanged);
document.addEventListener("fullscreenerror", onFullscreenChanged);

// handle mouse tigger zone
document.addEventListener("mousemove", function(e) {
    if (!settings.useMouse){
        return;
    }

    let mouseIsInTriggerZone = e.clientX < settings.triggerLeft
        || e.clientY < settings.triggerTop
        || document.documentElement.clientWidth - e.clientX < settings.triggerRight
        || document.documentElement.clientHeight - e.clientY < settings.triggerBottom;

    if (mouseIsInTriggerZone) {
        stateMachine.send("mouseTriggerZoneEntered");
    }
    else {
        stateMachine.send("mouseTriggerZoneExited");
    }
});

// handle hotkey
document.addEventListener("keydown", function(e) {
    let hotkeyMatches = settings.useHotkey && settings.hotkey
        && settings.hotkey.code == e.code
        && settings.hotkey.altKey == e.altKey
        && settings.hotkey.ctrlKey == e.ctrlKey
        && settings.hotkey.metaKey == e.metaKey
        && settings.hotkey.shiftKey == e.shiftKey;

    if (hotkeyMatches) {
        stateMachine.send("hotkey");
    }
});

// inject button to the addon option page
function updateInjectedOptionButton() {
    let optionButtonContainer = document.getElementById("hide-controls-options-button");

    if (optionButtonContainer && !settings.injectOptionButton) {
        // remove if option changed
        optionButtonContainer.style.display = "none";
        return;
    }
    else if (!optionButtonContainer && !settings.injectOptionButton) {
        return;
    }
    else if (optionButtonContainer) {
        // ignore if allready injected
        optionButtonContainer.style.display = "block";
        return;
    }

    const rightHeaderContainer = document.querySelector("ytd-masthead #end");

    if (!rightHeaderContainer) {
        setTimeout(() => updateInjectedOptionButton(), 1000);
        return;
    }

    optionButtonContainer = document.createElement("yt-icon-button");
    optionButtonContainer.id = "hide-controls-options-button";
    optionButtonContainer.setAttribute("label", "Hide Control Options");
    optionButtonContainer.className = "style-scope ytd-masthead";

    const iconElement = document.createElement("img");
    iconElement.src = chrome.runtime.getURL("icon.svg");
    iconElement.className = "style-scope ytd-masthead";
    optionButtonContainer.appendChild(iconElement);
    rightHeaderContainer.prepend(optionButtonContainer);

    let optionPopupElement = document.getElementById("hide-controls-option-popup");
    optionButtonContainer.addEventListener("click", () => {
        if (optionPopupElement) {
            if (optionPopupElement.style.display === "none") {
                optionPopupElement.style.display = "block";
            }
            else {
                optionPopupElement.style.display = "none";
            }
        }
        else {
            optionPopupElement = document.createElement("iframe");

            optionPopupElement.src = chrome.runtime.getURL("options/options.html");
            optionPopupElement.id = "hide-controls-option-popup";

            document.body.appendChild(optionPopupElement);
            document.addEventListener("keydown", (event) => {
                if ("Escape" === event.key) {
                    optionPopupElement.style.display = "none";
                }
            });
            document.addEventListener("click", (event) => {
                if (optionPopupElement.style.display !== "none"
                    && !optionButtonContainer.contains(event.target)
                    && !optionPopupElement.contains(event.target)
                ) {
                    optionPopupElement.style.display = "none";
                }
            });
        }
    });
}
