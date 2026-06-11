**From https://superuser.com/questions/1217378/windows-bitlocker-not-offering-unlock-by-password-option**

We'll actually look at a couple settings, make sure you have the following set, to completely disable TPM management and key use, and resort to password.

1. Open `gpedit.msc`.
2. Navigate to *Computer Configuration* &rarr; *Administrative Templates* &rarr; *Windows Components* &rarr; *BitLocker Drive Encryption* &rarr; *Operating System Drives*.
3. Set the following policy options:
    1. Require additional authentication at startup:
        1. Enabled.
        2. Allow BitLocker without a compatible TPM: Checked
        3. Configure TPM startup: Do not allow TPM
        4. Configure TPM startup PIN: Require startup PIN with TPM
        5. Configure TPM startup key: Do not allow startup key with TPM
        6. Configure TPM startup key and PIN: Do not allow startup key and PIN with TPM
    2. Allow enhanced PINs for startup: Enabled
    3. Configure use of passwords for operating system drives:
        1. Enabled
        2. Configure password complexity for operating system drives: Allow password complexity

And for non-system drives, be sure to have the following checkbox set:

1. Navigate to *Fixed Data Drives*.
2. Configure use of passwords for fixed data drives
    1. Enabled
    2. Require password for fixed data drive: Checked

I think that about covers it. It should now give you the option for password input. It also should work with strong passwords, and at startup. Hope this helps!
