# Simulator Finalization Team: The "Dream Team"
**Objective:** Take the Simulator from "Stable" to "World Class".
**Recommended Team Size:** 5 Specialized Agents.

To finish the development and make this the market leader, we need to move beyond "Code Fixes" into "Experience Engineering". Here is the proposed team:

---

## 🧠 Agent 1: The Psychologist (AI Behavior Specialist)
**"The Brain"**
*   **Mission:** Make the Consul feel *human*, unpredictable, and psychometrically accurate to real US Visa Officers.
*   **Tasks:**
    *   **Prompt Tuning:** Refine the "Harshness" dial. Eliminate robotic "I understand" phrases.
    *   **Scenario Injection:** Create specific "Trap Questions" for different visa types (Student vs. Tourist).
    *   **Memory Architecture:** Ensure the Consul "remembers" a lie told 10 turns ago and confronts the user.

## 🎨 Agent 2: The Visual Director (Frontend FX)
**"The Face"**
*   **Mission:** Break the "Chatbot" feel. The user should feel like they are in an office.
*   **Tasks:**
    *   **Dynamic Avatar:** Implement a CSS/SVG Consul that changes expression (Stern, Neutral, Angry) based on the `score` and `sentiment`.
    *   **Atmosphere:** Add subtle UI tension (e.g., a "Timer" bar or specific color shifts when risk increases).
    *   **Polish:** Typing animations that match the "stress" of the situation.

## 🎙️ Agent 3: The Voice Engineer (Audio/TTS)
**"The Voice"**
*   **Mission:** Interviews are *spoken*, not typed.
*   **Tasks:**
    *   **TTS Integration:** Implement OpenAI Audio or ElevenLabs to have the Consul *speak* the questions.
    *   **STT (Speech-to-Text):** Allow the user to *speak* their answers (Browser API or Whisper).
    *   **Latency Guard:** optimize strict streaming for audio to ensure it feels like a real conversation.

## 📊 Agent 4: The Analytics Officer (Data Science)
**"The Scorekeeper"**
*   **Mission:** Turn the "Game" into a "Training Tool".
*   **Tasks:**
    *   **Weakness Heatmap:** After the simulation, show the user *exactly* where they failed (e.g., "70% Weakness in Home Ties").
    *   **Progress Tracking:** "You improved 15% since your last attempt."
    *   **Global Benchmarking:** "You answered better than 80% of applicants."

## 🛡️ Agent 5: The QA Commando (Red Teaming)
**"The Breaker"**
*   **Mission:** Try to trick, break, or confuse the AI.
*   **Tasks:**
    *   **Troll Testing:** Spam the simulator with nonsense to ensure it terminates gracefully.
    *   **Jailbreak Defense:** Ensure users can't convince the Consul to "ignore previous instructions".
    *   **Load Testing:** Verify the Node.js runtime handles 100 concurrent simulations.

---

## Summary
| Agent | Focus | Outcome |
| :--- | :--- | :--- |
| **Psychologist** | Logic/Prompt | Realism |
| **Visual Director** | UI/CSS | Immersion |
| **Voice Engineer** | Audio API | Accessibility |
| **Analytics Officer** | DB/Charts | Value |
| **QA Commando** | Security | Reliability |

**Recommendation:** Start with **Agent 1 (Psychologist)** for purely logic improvements, or **Agent 2 (Visual Director)** for immediate "Wow Factor".
