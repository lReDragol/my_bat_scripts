# Установите имя пользователя, которому нужно предоставить права
# Пример: "Drago"
$targetUser = "Drago"

# Проверка аргумента (путь к папке)
if ($args.Count -eq 0) {
    Write-Host "Не указан путь к папке. Скрипт завершен." -ForegroundColor Red
    exit
}

# Получение пути из аргумента
$folderPath = $args[0]

# Проверка существования папки
if (-not (Test-Path $folderPath)) {
    Write-Host "Указанный путь не существует: $folderPath. Скрипт завершен." -ForegroundColor Red
    exit
}

# Функция для предоставления полного доступа
function Grant-FullAccess {
    param (
        [string]$path,
        [string]$user
    )

    # Экранируем путь и пользователя
    $escapedPath = "`"$path`""
    $escapedUser = "`"$user`""

    # Попытка снять запрещающие правила (Deny)
    try {
        Start-Process -FilePath "icacls.exe" -ArgumentList "$escapedPath /remove:d $escapedUser /T" -NoNewWindow -Wait
    } catch {
        Write-Host "Не удалось снять запреты для: $path" -ForegroundColor Red
    }

    # Попытка предоставить полный доступ
    try {
        Start-Process -FilePath "icacls.exe" -ArgumentList "$escapedPath /grant $escapedUser:F /T" -NoNewWindow -Wait
    } catch {
        Write-Host "Не удалось предоставить полный доступ для: $path" -ForegroundColor Red
    }
}

# Предоставление прав корневой папке
Write-Host "Предоставление прав корневой папке: $folderPath" -ForegroundColor Yellow
Grant-FullAccess -path $folderPath -user $targetUser

# Попытка сканировать и предоставить доступ
Write-Host "Проверка и предоставление прав в папке: $folderPath" -ForegroundColor Yellow
Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $itemPath = $_.FullName
    try {
        if (Test-Path $itemPath) {
            Write-Host "Обработка элемента: $itemPath" -ForegroundColor Cyan

            # Предоставить полный доступ
            Grant-FullAccess -path $itemPath -user $targetUser
        }
    } catch {
        Write-Host "Не удалось обработать элемент: $itemPath. Пропускаю." -ForegroundColor Red
    }
}

Write-Host "Все проверки завершены. Полный доступ предоставлен." -ForegroundColor Green
