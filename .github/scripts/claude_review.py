import json
import os
import sys
import urllib.request
import urllib.error


def main():
    tfsec_raw = open("tfsec-results.json").read() if os.path.exists("tfsec-results.json") else '{"results":[]}'
    tf_diff = open("tf.diff").read() if os.path.exists("tf.diff") else ""

    if len(tfsec_raw) > 4000:
        tfsec_raw = tfsec_raw[:4000] + "\n...(truncated)"
    if len(tf_diff) > 4000:
        tf_diff = tf_diff[:4000] + "\n...(truncated)"

    prompt = f"""Terraform IaC 코드 보안 리뷰를 한국어로 해주세요.

## tfsec 정적 분석 결과
{tfsec_raw}

## 변경된 Terraform 코드 (diff)
{tf_diff}

다음 형식으로 작성해주세요. 발견된 항목이 없는 섹션은 "없음"으로 표시하세요:

### 🔴 HIGH — 즉시 수정 필요
### 🟡 MEDIUM — 수정 권장
### 🟢 LOW — 참고 사항
### ✅ 수정 제안 (코드 포함)"""

    payload = {
        "model": "claude-haiku-4-5-20251001",
        "max_tokens": 1500,
        "messages": [{"role": "user", "content": prompt}]
    }

    req = urllib.request.Request(
        "https://api.anthropic.com/v1/messages",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "x-api-key": os.environ["ANTHROPIC_API_KEY"],
            "anthropic-version": "2023-06-01",
            "content-type": "application/json",
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as resp:
            result = json.loads(resp.read())
            print(result["content"][0]["text"])
    except urllib.error.HTTPError as e:
        print(f"Claude API 오류: {e.code} {e.read().decode()}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
