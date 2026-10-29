# Flask + Robot Framework + GitHub Actions

A small Flask web server for practicing continuous integration (CI). Six Robot
Framework tests send real HTTP requests to the running app. GitHub Actions starts
the server, runs the tests, and saves the results on every push and pull request.

## Project layout

```text
.
├── .github/workflows/robot-tests.yml  # CI workflow
├── .gitignore
├── app.py                            # Flask web server
├── requirements.txt                  # App and test dependencies
├── tests/web_app.robot               # HTTP tests
└── README.md
```

## Install dependencies

Use Python 3.13 to match CI. On macOS or Linux:

```bash
cd "/Users/rosdash/Documents/Work/rough/github actions"
python3.13 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

## Start the web server

In the same terminal:

```bash
python app.py
```

Open **http://127.0.0.1:5001/** in a browser. Keep this terminal running while you
test. Press **Ctrl+C** when you want to stop the server.

| Request | Response |
| --- | --- |
| `GET /` | HTML home page with `Hello from Flask!` |
| `GET /health` | `200` with `{"status": "ok"}` |
| `GET /hello` | `200` with `{"message": "Hello, World!"}` |
| `GET /hello?name=Robot` | `200` with `{"message": "Hello, Robot!"}` |
| `GET /hello?name=` | `400` with `{"error": "Name must not be empty"}` |
| `GET /does-not-exist` | `404` |

You can also make requests from a terminal:

```bash
curl http://127.0.0.1:5001/health
curl "http://127.0.0.1:5001/hello?name=Robot"
```

This example uses Flask's development server for local practice and CI.

## Run the Robot tests

Open a **second terminal**, activate the same virtual environment, and run:

```bash
cd "/Users/rosdash/Documents/Work/rough/github actions"
source .venv/bin/activate
python -m robot --outputdir results --xunit xunit.xml tests
```

Expect `6 tests, 6 passed, 0 failed`. Open `results/report.html` for the summary
or `results/log.html` for request details and failure messages. Robot also writes
`results/output.xml` and `results/xunit.xml` for tools that consume test results.

The suite uses `RequestsLibrary` to check HTTP status codes, HTML, and JSON:

```robotframework
Default Greeting Says Hello To World
    ${response}=    GET    ${BASE_URL}/hello    expected_status=200    timeout=5
    Should Be Equal    ${response.json()}[message]    Hello, World!
```

Suite setup retries `/health` for up to 15 seconds so the server has time to
start. Requests have timeouts, and a failed test returns a nonzero exit code.
Use at least two spaces between Robot keywords and their arguments.

If port 5001 is busy, start the server on a different port and point the tests
at it:

```bash
# First terminal, instead of python app.py:
python -m flask --app app run --host 127.0.0.1 --port 5002

# Second terminal:
python -m robot --variable BASE_URL:http://127.0.0.1:5002 --outputdir results --xunit xunit.xml tests
```

## Upload to GitHub

**Put this folder's contents at the repository root**, including the hidden
`.github` folder. The workflow must appear at
`.github/workflows/robot-tests.yml`, with `app.py` and `requirements.txt` at the
root. Do not wrap these files in another `github actions/` folder in the repo.

On macOS, **Command + Shift + .** shows hidden files in Finder. If uploading
manually, include `.github/workflows/robot-tests.yml` and `.gitignore`; leave out
`.venv/`, `__pycache__/`, and `results/`. Upload the files, not a ZIP archive.

Alternatively, create an **empty** GitHub repository without a README, license,
or gitignore, then run these commands from this folder. Replace `YOUR_USERNAME`
and the repository name in the URL:

```bash
git init -b main
git add .
git commit -m "Add Flask web server and Robot Framework CI"
git remote add origin https://github.com/YOUR_USERNAME/flask-ci-practice.git
git push -u origin main
```

Git includes `.github` automatically and excludes generated files through
`.gitignore`.

## What GitHub Actions does

The workflow runs on pushes, pull requests, and manual starts:

1. Checks out the repository and sets up Python 3.13.
2. Installs `requirements.txt`.
3. Starts Flask in the background, saving its output to `results/server.log`.
4. Runs Robot; suite setup waits for the health endpoint before testing.
5. Stops Flask when the test step finishes, including when tests fail.
6. Uploads the `results/` folder even if a test fails, retaining it for seven days.

After uploading, open **Actions → Robot Framework CI** and select a run. Expand
**Start Flask and run Robot Framework tests** to see the test output. Download
**robot-test-results** from the run's artifacts and open the HTML reports or
`server.log`.

For a manual run, use **Run workflow** after the workflow is on the default
branch. No repository secrets are required. If the workflow does not appear,
check its root path and **Settings → Actions → General**; organization policies
may restrict Actions.

## Practice a failing build

1. In `tests/web_app.robot`, change the default greeting expectation from
   `Hello, World!` to `Hello, Moon!`.
2. Run locally, then commit and push. Observe the failed CI run and its reports.
3. Restore `Hello, World!`, commit, and push to see the build pass again.

For another exercise, add an endpoint and a Robot test, push a branch, and open
a pull request to see CI run on the PR.

## References

- [Flask quickstart](https://flask.palletsprojects.com/en/stable/quickstart/)
- [Robot Framework RequestsLibrary](https://github.com/MarketSquare/robotframework-requests)
- [GitHub: Building and testing Python](https://docs.github.com/en/actions/tutorials/build-and-test-code/python)


run1