import requests
from fastapi import FastAPI, Request, Response, status
from fastapi.middleware.cors import CORSMiddleware
from starlette.staticfiles import StaticFiles

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "ient-mobile.vercel.app"],
    allow_methods=["*"],
    allow_credentials=True,
    allow_headers=["*"],
)

@app.api_route(
    "/api/",
    methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
)
async def proxy(request: Request):
    url = request.query_params.get("url")
    if not url:
        return Response(
            content="URL manquante", status_code=status.HTTP_400_BAD_REQUEST
        )

    if request.method == "OPTIONS":
        return Response(status_code=status.HTTP_200_OK)

    headers_cible = dict(request.headers)
    headers_cible.pop("host", None)
    headers_cible.pop("Host", None)

    headers_cible.pop("referer", None)
    headers_cible.pop("origin", None)
    print(request.cookies)
    print(headers_cible)

    corps = await request.body()

    session = requests.Session()
    response_cible = session.request(
        method=request.method,
        url=url,
        headers=headers_cible,
        data=corps,
        allow_redirects=True,
        cookies=request.cookies,
    )
    headers_finaux = dict(response_cible.headers)

    headers_to_pop = [
        "content-length", "Content-Length",
        "content-encoding", "Content-Encoding",
        "transfer-encoding", "Transfer-Encoding",
        "set-cookie", "Set-Cookie",
        "access-control-allow-origin", "Access-Control-Allow-Origin",
        "access-control-allow-credentials", "Access-Control-Allow-Credentials"
    ]
    for header in headers_to_pop:
        headers_finaux.pop(header, None)

    headers_finaux["finish_link"] = response_cible.url

    status_code_final = response_cible.status_code

    reponse_finale = Response(
        content=response_cible.content,
        status_code=status_code_final,
        headers=headers_finaux,
    )
    reponse_finale.headers["Access-Control-Expose-Headers"] = "location, set-cookie, finish_link"

    for cookie in response_cible.cookies:
        reponse_finale.set_cookie(
            key=cookie.name,
            value=cookie.value,
            httponly=True,
            samesite="lax",
            secure=False,
            path="/"
        )

    return reponse_finale

app.mount("/", StaticFiles(directory="./web", html=True), name="web")