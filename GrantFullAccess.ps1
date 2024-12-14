# ���������� ��� ������������, �������� ����� ������������ �����
# ������: "Drago"
$targetUser = "Drago"

# �������� ��������� (���� � �����)
if ($args.Count -eq 0) {
    Write-Host "�� ������ ���� � �����. ������ ��������." -ForegroundColor Red
    exit
}

# ��������� ���� �� ���������
$folderPath = $args[0]

# �������� ������������� �����
if (-not (Test-Path $folderPath)) {
    Write-Host "��������� ���� �� ����������: $folderPath. ������ ��������." -ForegroundColor Red
    exit
}

# ������� ��� �������������� ������� �������
function Grant-FullAccess {
    param (
        [string]$path,
        [string]$user
    )

    # ���������� ���� � ������������
    $escapedPath = "`"$path`""
    $escapedUser = "`"$user`""

    # ������� ����� ����������� ������� (Deny)
    try {
        Start-Process -FilePath "icacls.exe" -ArgumentList "$escapedPath /remove:d $escapedUser /T" -NoNewWindow -Wait
    } catch {
        Write-Host "�� ������� ����� ������� ���: $path" -ForegroundColor Red
    }

    # ������� ������������ ������ ������
    try {
        Start-Process -FilePath "icacls.exe" -ArgumentList "$escapedPath /grant $escapedUser:F /T" -NoNewWindow -Wait
    } catch {
        Write-Host "�� ������� ������������ ������ ������ ���: $path" -ForegroundColor Red
    }
}

# �������������� ���� �������� �����
Write-Host "�������������� ���� �������� �����: $folderPath" -ForegroundColor Yellow
Grant-FullAccess -path $folderPath -user $targetUser

# ������� ����������� � ������������ ������
Write-Host "�������� � �������������� ���� � �����: $folderPath" -ForegroundColor Yellow
Get-ChildItem -Path $folderPath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
    $itemPath = $_.FullName
    try {
        if (Test-Path $itemPath) {
            Write-Host "��������� ��������: $itemPath" -ForegroundColor Cyan

            # ������������ ������ ������
            Grant-FullAccess -path $itemPath -user $targetUser
        }
    } catch {
        Write-Host "�� ������� ���������� �������: $itemPath. ���������." -ForegroundColor Red
    }
}

Write-Host "��� �������� ���������. ������ ������ ������������." -ForegroundColor Green
