function Read-IniFile($Filename, $Section, $Key, $DefaultValue) {
    if (-not (Test-Path $Filename)) {
        return $DefaultValue;
    }

    $line = '';
    switch -Regex -File $Filename {
        '^\[(.+)\]$' {
            if ($line -eq $Section) {
                return $DefaultValue;
            }

            $line = $Matches[1];
            continue;
        }
        '^([^=;#]+?)\s*=\s*(.*)$' {
            if ($line -eq $Section -and $Matches[1] -eq $Key) {
                return $Matches[2] -replace '\s*;.*$';
            }
        }
    }

    return $DefaultValue;
}

function Write-IniFile($Filename, $Section, $Key, $Value) {
    if (Test-Path $Filename) {
        $lines = [System.Collections.Generic.List[string]](Get-Content $Filename);
    }
    else {
        $lines = [System.Collections.Generic.List[string]]::new();
    }

    $line = '';
    $keyIndex = -1;
    $sectionEndIndex = $lines.Count;

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^\[(.+)\]$') {
            if ($line -eq $Section) {
                $sectionEndIndex = $i;
                break;
            }

            $line = $Matches[1];
        }
        elseif ($line -eq $Section -and $lines[$i] -match '^([^=;#]+?)\s*=') {
            if ($Matches[1] -eq $Key) {
                $keyIndex = $i;
                break;
            }
        }
    }

    if ($keyIndex -ge 0) {
        $lines[$keyIndex] = "$Key=$Value";
    }
    elseif ($line -eq $Section) {
        $lines.Insert($sectionEndIndex, "$Key=$Value");
    }
    else {
        if ($lines.Count -gt 0 -and $lines[$lines.Count - 1] -ne '') {
            $lines.Add('');
        }

        $lines.Add("[$Section]");
        $lines.Add("$Key=$Value");
    }

    Set-Content -Path $Filename -Value $lines;
}