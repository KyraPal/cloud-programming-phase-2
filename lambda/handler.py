from pathlib import Path

html_file = Path(__file__).with_name("index.html")
PAGE = html_file.read_text(encoding="utf-8")

def lambda_handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"Content-Type": "text/html; charset=utf-8"},
        "body": PAGE,}