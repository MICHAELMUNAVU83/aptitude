# Phoenix AI Aptitude Test — Product Documentation

## What Is This App?

Phoenix AI Aptitude Test is a web application that lets an admin create and send AI-generated aptitude tests to candidates. The candidate receives a link by email, opens it, and completes the test within a set time. When the test is done, the system automatically grades the answers and generates an AI report on how the candidate performed.

---

## How It Works — The Big Picture

```
Admin fills in test details
        ↓
AI generates questions & answers
        ↓
System saves the test + sends email to candidate
        ↓
Candidate opens email → clicks link → timer starts
        ↓
Candidate answers questions (answers auto-save as they go)
        ↓
Time runs out (or candidate submits) → answers saved
        ↓
AI analyses results → report generated → saved
```

---

## The Two Main Users

**Admin** — The person setting up and sending the test.
**Candidate** — The person taking the test.

---

## Features

### 1. Test Setup (Admin Side)

The admin fills in a simple form before the test is created:

| Field | Description |
|---|---|
| Candidate Email | Where the test link will be sent |
| Sector / Topic | e.g. General Knowledge, Marketing, Software Engineering, Finance, HR |
| Difficulty | Easy, Medium, or Hard |
| Time Limit | How many minutes the candidate has (e.g. 30, 45, 60 minutes) |
| Number of Questions | How many questions to generate |

Once submitted, the system uses OpenAI to generate the questions and correct answers, saves them to the database, and sends the test link to the candidate.

---

### 2. AI Question Generation

- OpenAI generates questions based on the sector, difficulty, and number of questions chosen.
- Questions are multiple choice (4 options each) with one correct answer.
- Questions and answers are saved in the database before the email is sent.
- The candidate never sees the answers — only the questions.

---

### 3. Email Delivery

- The candidate receives a clean email with a unique link to their test.
- The link is tied to their specific test session — no login required.
- The link can only be used for that one test.

---

### 4. Timer Behaviour

- The timer starts the moment the candidate opens the test link.
- The start time is saved in the database immediately.
- If the candidate closes the browser and reopens the link, the timer continues from where it left off — it does not reset.
- When time runs out, the test is automatically submitted with whatever answers the candidate has given so far.

**How this works technically (for Claude Code):**
- On first open → record `started_at` timestamp in database.
- On every open → calculate `time_remaining = time_limit - (now - started_at)`.
- Use Phoenix PubSub to broadcast timer ticks to the candidate's browser in real time.
- When `time_remaining` hits zero → trigger auto-submit.

---

### 5. Auto-Save

- Every time a candidate selects an answer, it is saved to the database immediately.
- There is also a periodic background save every 30 seconds, just in case.
- This means if the browser crashes or the tab is closed, no answers are lost.

---

### 6. Test Submission

The test can end in two ways:

1. **Candidate clicks Submit** — answers are marked final, result is processed.
2. **Timer runs out** — system automatically submits whatever is saved.

After submission, the candidate sees a simple "Test completed. Thank you." message.

---

### 7. AI Results & Report

After submission, OpenAI analyses the candidate's answers and generates a report that includes:

- **Score** — how many questions answered correctly, shown as a percentage.
- **Performance by topic** — if multiple sub-topics exist within the sector, a breakdown of how they did in each.
- **Strengths** — areas where they did well.
- **Weaknesses** — areas where they struggled.
- **Overall summary** — a short paragraph giving a human-readable verdict on the candidate's performance.

The report is saved to the database and can be viewed by the admin at any time.

---

## Data That Gets Saved

| What | When |
|---|---|
| Test configuration (sector, difficulty, timing) | When admin creates the test |
| Generated questions + correct answers | Before email is sent |
| Candidate email + unique test token | When test is created |
| Timer start time | When candidate first opens the link |
| Each answer the candidate selects | Immediately when selected + every 30s |
| Final submitted answers | On submit or timeout |
| AI-generated results report | After submission is processed |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Web framework | Phoenix (Elixir) |
| Real-time (timer, live updates) | Phoenix LiveView + Phoenix PubSub |
| AI (questions + report) | OpenAI API (GPT-4) |
| Email delivery | Swoosh (Phoenix mailer) |
| Database | PostgreSQL |
| Background jobs | Oban (for timed auto-submit) |

---

## Database Tables (Simple Overview)

**tests**
Holds one row per test created by the admin. Stores the sector, difficulty, time limit, candidate email, and the unique access token.

**questions**
Holds the AI-generated questions for each test. Each question has four answer options and the correct answer stored.

**answers**
Holds the candidate's selected answers. Updated in real time as they answer. One row per question per test session.

**results**
Holds the final score and AI report for each completed test. Created after submission.

---

## Pages / Screens

### Admin
- **Create Test page** — form to fill in candidate email, sector, difficulty, timing.
- **Test List page** — list of all tests created, with status (Sent / In Progress / Completed).
- **Result Detail page** — view the AI report and score for a completed test.

### Candidate
- **Test page** — shows questions one at a time or all at once, with a visible countdown timer.
- **Completion page** — simple thank-you screen after submission.

---

## Key Behaviours to Implement in Code

1. **Unique token per test** — generate a secure random token when a test is created. The candidate's link looks like `/test/:token`.

2. **Timer persistence** — save `started_at` to the database on first visit. On every visit, read from the database, not from the browser.

3. **PubSub timer** — use a Phoenix PubSub topic per test session (e.g. `test:{token}`) to broadcast countdown ticks every second to the LiveView. When the counter hits zero, broadcast a `:time_up` event that triggers auto-submit.

4. **Auto-save** — on every answer change event in LiveView, immediately update the `answers` table. Also run a periodic save using `Process.send_after` every 30 seconds.

5. **Idempotent submission** — make sure submitting twice (e.g. user clicks submit AND timer runs out at the same time) only processes the result once. Use a `submitted_at` timestamp field and check it before processing.

6. **OpenAI for questions** — call OpenAI when the admin submits the test creation form. Ask it to return JSON with questions, options, and correct answers. Save this before sending the email.

7. **OpenAI for report** — after submission, pass the questions, the correct answers, and the candidate's answers to OpenAI. Ask it to return a JSON report with score, strengths, weaknesses, and a summary paragraph.

8. **Email with link** — use Swoosh to send the candidate a simple HTML email containing their unique test link and the time limit.

---

## Example OpenAI Prompt (Question Generation)

```
You are an exam creator. Generate {n} multiple choice questions for a {difficulty} level 
aptitude test on the topic of {sector}. 

Return JSON only in this format:
{
  "questions": [
    {
      "question": "...",
      "options": ["A. ...", "B. ...", "C. ...", "D. ..."],
      "correct_answer": "A"
    }
  ]
}
```

---

## Example OpenAI Prompt (Results Analysis)

```
You are an expert assessor. A candidate completed a {sector} aptitude test at {difficulty} level.

Here are the questions, correct answers, and the candidate's answers:
{questions_and_answers_json}

Analyse the results and return JSON only in this format:
{
  "score_percentage": 75,
  "correct_count": 15,
  "total_questions": 20,
  "strengths": ["..."],
  "weaknesses": ["..."],
  "summary": "..."
}
```

---

## What the Admin Sees After a Test Is Completed

- Candidate name / email
- Score (e.g. 15/20 — 75%)
- Time taken
- Strengths identified by AI
- Weaknesses identified by AI
- Overall AI summary paragraph
- Option to download or share the report

---

## Notes for Development

- Start with the test creation flow and question generation before building the candidate-facing test page.
- Get the timer working with PubSub early — it is the trickiest part.
- Auto-save should be implemented before testing the full flow end to end.
- Use Oban for the background job that force-submits when time expires, in case the candidate's browser is closed.
- Keep the candidate-facing UI simple and distraction-free.