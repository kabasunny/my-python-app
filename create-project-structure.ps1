# .env ファイルのパス
$envFilePath = ".env"

# .env ファイルの読み込み
if (Test-Path $envFilePath) {
    Get-Content $envFilePath | ForEach-Object {
        # 空行やコメント行を無視
        if ($_ -match "^\s*#") { return }
        if ($_ -match "^\s*$") { return }
        # 環境変数を設定
        $name, $value = $_ -split "=", 2
        $name = $name.Trim()
        $value = $value.Trim()
        [System.Environment]::SetEnvironmentVariable($name, $value)
    }
}

# 環境変数を使用
$rootPath = $env:ROOT_PATH
Write-Output "Root path is: $rootPath"

# ディレクトリの作成
New-Item -ItemType Directory -Path $rootPath -Force
New-Item -ItemType Directory -Path "$rootPath/data-analysis" -Force

# Dockerfile の作成
$dockerfileContent = @"
FROM python:3.10

WORKDIR /app

COPY ./data-analysis/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["python", "app.py"]
"@
New-Item -ItemType File -Path "$rootPath/data-analysis/Dockerfile" -Value $dockerfileContent -Force
Write-Output "Dockerfile has been created."

# requirements.txt の作成
$requirementsContent = @"
flask
numpy
pandas
python-dotenv
"@
New-Item -ItemType File -Path "$rootPath/data-analysis/requirements.txt" -Value $requirementsContent -Force
Write-Output "requirements.txt has been created."

# シンプルなPythonアプリの作成
$appPyContent = @"
from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, World!'

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
"@
New-Item -ItemType File -Path "$rootPath/data-analysis/app.py" -Value $appPyContent -Force
Write-Output "app.py has been created."

# docker-compose.yml の作成
$dockerComposeContent = @"
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: ./data-analysis/Dockerfile
    ports:
      - '5000:5000'
    volumes:
      - ./data-analysis:/app
"@
New-Item -ItemType File -Path "$rootPath/docker-compose.yml" -Value $dockerComposeContent -Force
Write-Output "docker-compose.yml has been created."

# .gitignore の作成
$gitignoreContent = @"
.env
"@
New-Item -ItemType File -Path "$rootPath/.gitignore" -Value $gitignoreContent -Force
Write-Output ".gitignore has been created."

# Dockerコンテナの起動
docker-compose up --build
Write-Output "Directory structure has been created and Python app initialized."
