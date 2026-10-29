*** Settings ***
Documentation     Test the running Flask web server through HTTP requests.
Library           RequestsLibrary
Suite Setup       Wait Until Keyword Succeeds    15s    1s    Server Should Be Healthy


*** Variables ***
${BASE_URL}       http://127.0.0.1:5001


*** Test Cases ***
Home Page Welcomes Visitors
    ${response}=    GET    ${BASE_URL}/    expected_status=200    timeout=5
    Should Contain    ${response.text}    <h1>Hello from Flask!</h1>
    Should Contain    ${response.headers}[Content-Type]    text/html

Health Endpoint Reports OK
    Server Should Be Healthy

Default Greeting Says Hello To World
    ${response}=    GET    ${BASE_URL}/hello    expected_status=200    timeout=5
    Should Be Equal    ${response.json()}[message]    Hello, World!

Greeting Uses The Supplied Name
    &{params}=    Create Dictionary    name=Robot
    ${response}=    GET    ${BASE_URL}/hello    params=${params}    expected_status=200    timeout=5
    Should Be Equal    ${response.json()}[message]    Hello, Robot!

Blank Name Is Rejected
    &{params}=    Create Dictionary    name=${SPACE}
    ${response}=    GET    ${BASE_URL}/hello    params=${params}    expected_status=400    timeout=5
    Should Be Equal    ${response.json()}[error]    Name must not be empty

Unknown Page Returns Not Found
    GET    ${BASE_URL}/does-not-exist    expected_status=404    timeout=5


*** Keywords ***
Server Should Be Healthy
    ${response}=    GET    ${BASE_URL}/health    expected_status=200    timeout=2
    Should Be Equal    ${response.json()}[status]    ok
    Should Contain    ${response.headers}[Content-Type]    application/json
