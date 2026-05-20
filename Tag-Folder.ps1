function Read-IniFile {
    param (
        [Parameter(Mandatory)]
        [string]$Filename,

        [string]$Section = '',

        [Parameter(Mandatory)]
        [string]$Key,

        [string]$DefaultValue = ''
    );

    $DefaultValue = $DefaultValue.Trim();

    if (-not (Test-Path -Path $Filename -PathType Leaf)) {
        return $DefaultValue;
    }

    $line = '';
    switch -Regex -File $Filename {
        '^\[(.+)\]$' {
            if ($line -eq $Section) {
                return $DefaultValue;
            }

            $line = $Matches[1].Trim();
            continue;
        }
        '^([^=;#]+?)\s*=\s*(.*)$' {
            if ($line -eq $Section -and $Matches[1].Trim() -eq $Key) {
                $value = $Matches[2].Trim() -replace '\s*[;#].*$';
                $value = $value -replace '^(["''])(.*)\1$', '$2';

                return $value;
            }
        }
    }

    return $DefaultValue;
}

function Write-IniFile {
    param (
        [Parameter(Mandatory)]
        [string]$Filename,

        [string]$Section = '',

        [Parameter(Mandatory)]
        [string]$Key,

        [Parameter(Mandatory)]
        [string]$Value
    );

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

function Show-TagDialog {
    param (
        [string]$InitialValue = ''
    );

    Add-Type -AssemblyName System.Windows.Forms;
    Add-Type -AssemblyName System.Drawing;

    $form = [System.Windows.Forms.Form]@{
        Text = 'Enter Tag';
        Size = New-Object System.Drawing.Size(320, 125);
        StartPosition = 'CenterScreen';
        FormBorderStyle = 'FixedDialog';
        MaximizeBox = $false;
        MinimizeBox = $false;
    };

    $label = [System.Windows.Forms.Label]@{
        Text = 'Tag:';
        Location = New-Object System.Drawing.Point(15, 15);
        AutoSize = $true;
    };

    $textBox = [System.Windows.Forms.TextBox]@{
        Location = New-Object System.Drawing.Point(50, 12);
        Width = 235;
        Text = $InitialValue;
    };

    $okButton = [System.Windows.Forms.Button]@{
        Text = 'OK';
        Location = New-Object System.Drawing.Point(125, 45);
        Size = New-Object System.Drawing.Size(75, 25);
        DialogResult = 'OK';
    };

    $cancelButton = [System.Windows.Forms.Button]@{
        Text = 'Cancel';
        Location = New-Object System.Drawing.Point(210, 45);
        Size = New-Object System.Drawing.Size(75, 25);
        DialogResult = 'Cancel';
    };

    $form.AcceptButton = $okButton;
    $form.CancelButton = $cancelButton;
    $form.Controls.AddRange(@($label, $textBox, $okButton, $cancelButton));

    $dialogResult = $form.ShowDialog();
    $tag = $textBox.Text.Trim();
    $form.Dispose();

    return @{
        Result = $dialogResult;
        Tag = $tag;
    };
}

function Set-FolderTag {
    param (
        [Parameter(Mandatory)]
        [string]$FolderPath
    );

    $iniPath = Join-Path $FolderPath 'desktop.ini';
    $section = '{F29F85E0-4FF9-1068-AB91-08002B27B3D9}';
    $key = 'Prop5';

    $rawValue = Read-IniFile $iniPath $section $key '';
    $currentTag = if ($rawValue -match '^31,(.*)$') {
        $Matches[1];
    }
    else {
        '';
    };

    $response = Show-TagDialog $currentTag;
    if ($response.Result -eq 'OK') {
        Write-IniFile $iniPath $section $key "31,$( $response.Tag )";

        attrib +h +s $iniPath;
        attrib +s $FolderPath;
    }
}


Set-FolderTag $args[0];