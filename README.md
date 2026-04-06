# Aptitude Test

Aptitude Test is an AI-powered candidate assessment platform built with Phoenix LiveView. Hiring teams can create a timed aptitude test for a candidate, send a unique link instantly, and review an AI-assisted report once the candidate submits.

Production site: https://aptitudetest.info



<img width="1440" height="775" alt="Screenshot 2026-04-06 at 20 24 28" src="https://github.com/user-attachments/assets/002d19c0-b106-4f4f-a075-1d7b4b7fd25a" />


## What the app does

- Lets an authenticated admin create a test for a candidate
- Uses OpenAI to generate multiple-choice questions based on sector, difficulty, and question count
- Emails the candidate a unique public test link
- Runs the candidate test in a focused timed interface with answer autosave
- Submits the test manually or automatically when time runs out
- Generates an AI report with score, strengths, weaknesses, red flags, sub-topic analysis, and interviewer probe questions
- Gives the admin a dashboard for sent, in-progress, and completed tests

## Current product flow

1. Admin signs in and creates a test.
2. The app creates a secure token and saves the test.
3. OpenAI generates the questions.
4. The candidate receives a branded invitation email.
5. The candidate opens the link and the timer starts on first visit.
6. Answers are saved immediately as the candidate works through the test.
7. When the test is submitted, the app marks it complete and starts AI result analysis.
8. The candidate sees a completion screen and the admin can review the generated report.

## Implemented features

### Admin side

- User authentication for admins
- Landing page for product marketing and sign-up
- Create test form with:
  - candidate email
  - sector/topic
  - difficulty
  - time limit
  - number of questions
- Test list dashboard with statuses:
  - sent
  - in progress
  - completed
- Test detail screen showing questions and candidate answers
- Result detail screen with AI-generated evaluation
- Ability to resend invitation emails for uncompleted tests
- Ability to manually generate a report for completed tests that do not have one yet

### Candidate side

- Token-based public test access at `/test/:token`
- No login required for candidates
- Countdown timer based on persisted `started_at`
- Immediate answer saving on every selection
- Keyboard navigation with left and right arrow keys
- Auto-submit when time reaches zero
- Submission completion screen

### AI and email workflows

- OpenAI question generation using the configured API key
- OpenAI result analysis after submission
- Invitation email to candidate
- Submission confirmation email to candidate
- Completion notification email to the test owner

## Stack

- Elixir
- Phoenix 1.7
- Phoenix LiveView
- Ecto + PostgreSQL
- OpenAI API via `Req`
- Tailwind CSS
- Esbuild

## Local development

### Requirements

- Elixir 1.14+
- Erlang/OTP compatible with the project
- PostgreSQL running locally

### Environment variables

The project loads `.env` automatically from `mix.exs`, so you do not need to run `source .env` before starting the app.

At minimum, development expects:

- `OPENAI_API_KEY`

Production also uses standard Phoenix runtime variables such as:

- `DATABASE_URL`
- `SECRET_KEY_BASE`
- `PHX_HOST`
- `PORT`

### Setup

```bash
mix setup
```

This will:

- fetch dependencies
- create and migrate the database
- seed the database
- install asset tooling
- build frontend assets

### Start the app

```bash
mix phx.server
```

Local development runs on:

- http://localhost:7110

You can also start it in IEx:

```bash
iex -S mix phx.server
```

## Database overview

Main domain tables:

- `tests`: one record per candidate test
- `questions`: generated questions attached to a test
- `answers`: candidate selections per question
- `results`: AI-generated report for a completed test
- `users`: authenticated admin users

Important persisted fields in the test flow:

- `token`
- `status`
- `started_at`
- `submitted_at`

## Key routes

- `/` marketing landing page
- `/users/register` admin registration
- `/users/log_in` admin login
- `/admin` test dashboard
- `/admin/tests/new` create test
- `/admin/tests/:id` test detail
- `/admin/tests/:id/result` result detail
- `/test/:token` candidate test page
- `/test/:token/done` candidate completion page

## Notes on behavior

- Candidate test links are token-gated and public
- The timer starts on first candidate visit, not when the test is created
- Answers are written to the database as the candidate selects them
- Submission is idempotent through the persisted `submitted_at` state
- Result generation is triggered asynchronously after submission
- SEO metadata and branding are configured for `aptitudetest.info`

## Testing

Run the test suite with:

```bash
mix test
```

## Deployment

The app is configured as a standard Phoenix application with runtime config in `config/runtime.exs`.

Before production startup, ensure the runtime environment includes the required values for database connectivity, host configuration, and Phoenix secrets.
