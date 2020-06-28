# turn off password expiry
wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

# turn off computer password
New-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "DisablePasswordChange" -PropertyType DWORD -Value 1 -Force

# 0 hibernation file
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateFileSizePercent" -PropertyType DWORD -Value 0 -Force

# diable hiberation
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Power\" -Name "HibernateEnabled" -PropertyType DWORD -Value 0 -Force
