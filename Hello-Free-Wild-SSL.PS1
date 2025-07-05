##########################################################################
#                                                                        #
# Hello-Free-Wild-SSL.PS1, ver 2.0.0, a utility for Let's Encrypt DV SSL #
#                                                                        #
##########################################################################

# script scope consts:
$script:ZGU        = "  \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/  ";
$script:ZGD        = "  /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  ";
$script:BAR        = "                                                                              ";
$script:ABR        = "       < Press [Ctrl] + [C] to exit script or abort a process anytime >       ";
$script:NL         = "`n";
$script:RT         = "`r`n";
$script:SHW        =  300;
$script:PRO        =  30;
$script:AUT        =  600;
$script:USER       = "Profile";
$script:MsgOptIn   = "Firstly, create/choose the required $USER using option ""New/Set $USER"" !";
$script:MsgConfirm = "Type [C] to confirm or any to exit and press [Enter]...";
$script:MsgCheck   = "Something went wrong! You may start over this process!";
$script:MsgSkipErr = "Type [S] to start over or any to exit script and press [Enter]...";
$script:SSLPKSAME  = "Same Private Key";
$script:SSLPKNEW   = "New Private Key";
$script:AFF        = " $RT - Type [V] to visit(new affiliation window) the website yourself, or... $NL - any to end paging and press [Enter]... $RT ";
$script:LNK        = " $RT - Type [V] to visit(new window) the website yourself, or... $NL - any to end paging and press [Enter]... $RT ";
$script:CRT        =
"
Sorry for this ""Workaround Help"", but sometimes: 
 - You may restart terminal/script and...
 - You may start new with/without a different $USER for the required domain or...
 - You may restart this process again after deleting/emptying/moving locally cached $USER folder!
   * Sometimes you may need to clear all cached files under the cert(s) output directory
     that can be found when looking for a folder. and start this process again...
     See: Legal -> Extra...Links -> Posh...Save-To...Folder.
 - SSL got with older soft version(s) then with newer while there is some addons/drops also...
 - mostly needs a new start with a new $USER.

       Kindly, press [Enter] to exit this script $RT 
";
$script:BYE = " $NL Bye ! $NL ";

# script scope vars named after function or thread/task/step lock:
$script:GetStatus              = $false;
$script:StartOver              = $false;
$script:GetInput               = $false;
$script:GoNext0                = $false;
$script:GoNext1                = $false;
$script:OptionsMenu            = $false;
$script:TestSSLConnection      = $false;
$script:NewSetAccount          = $false;
$script:NewRenewSSL            = $false;
$script:DomainCheck            = $false;
$script:Help                   = $false;
$script:Legal                  = $false;
$script:CCCSettings            = $false;
$script:ScriptCycle            = $false;

# script scope vars named after global info fields:
$script:connec    = $false;
$script:status    = "NA";
$script:authority = $null;
$script:modes     = $null;
$script:sslpkey   = $null;
$script:domain    = $null;
$script:alias     = $null;
$script:email     = $null;
$script:id        = $null;
$script:folder    = $null;

# script scope var for cycle options/steps chosen/reached:
$script:step = 1;

#######################################################################
function SetPoshACME
{
    try
    {
        # Set Execution Policy just once for this time to import Posh-ACME
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force;
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force;
        $ExecutionContext.SessionState.LanguageMode = [System.Management.Automation.PSLanguageMode]::FullLanguage;
        $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop;
        $WarningActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue;
    }
    catch{ return -1; }

    try
    {
        # Import Posh-ACME module
        Import-Module Posh-ACME -DisableNameChecking -Scope Global -NoClobber -Force;
    }
    catch{ return -2; }
 
    # wait...
    sleep -Milliseconds $PRO;

    return 1;
}

#######################################################################
function GetPoshACME
{
    try
    {
        # Next - Header >>>
        GoNext -title "This Script -> Installation -> Posh-ACME" -flg 5;

            # Install Posh-ACME module
            Install-Module "Posh-ACME" -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Verbose -Force;

        # Next - Footer >>>
        GoNext -flg 6;

        Write-Host $RT;
        Write-Host $RT;
        Write-Host $RT;
    }
    catch{ return $false; }

    # wait...
    sleep -Milliseconds $PRO;

    return $true;
}

#######################################################################
function GetInput
{
    Param
    (
        [Parameter(Mandatory=$false, HelpMessage="-msg: Default = Press [Enter] to continue...")]
        [string]
        $msg = "Press [Enter] to continue...",
        [Parameter(Mandatory=$false, HelpMessage="-style: 0 = White, 1 = Red, 2 = Yellow.")]
        [int]
        $style = 0
    );

    # locking <>
    if($script:GetInput -eq $true){ return; }
    $script:GetInput = $true;

    # Normal style as Default - White
    $clrFor = 15;
    $clrBkg = 15;

    # Confirm style as Requied - Red
    if($style -eq 1)
    {
        $clrFor = 12;
        $clrBkg = 12;
    }

    # Confirm style as Advisory - Yellow
    if($style -eq 2)
    {
        $clrFor = 14;
        $clrBkg = 14;
    }

    # Confirm style as Inactive - DarkYellow
    if($style -eq 3)
    {
        $clrFor = 6;
        $clrBkg = 6;
    }

    # color & lines
    Write-Host $RT  -NoNewline;
    Write-Host $BAR -NoNewline -ForegroundColor $clrFor -BackgroundColor $clrBkg;
    Write-Host $RT  -NoNewline;
    Write-Host $ABR -NoNewline;
    Write-Host $RT  -NoNewline;
    Write-Host $BAR -NoNewline -ForegroundColor $clrFor -BackgroundColor $clrBkg;
    Write-Host $RT  -NoNewline;

    # Wait...
    sleep -Milliseconds $SHW;

    # Input = string
    $msg = $msg.Trim();
    $msg = "> $msg $RT ::";
    $ret = Read-Host -Prompt $msg -ErrorAction SilentlyContinue;

    # Wait...
    sleep -Milliseconds $PRO;

    # locking <>
    $script:GetInput = $false;

    # exit
    return($ret);
}

#######################################################################
function GetStatus
{
    # locking <>
    if($script:GetStatus -eq $true){ return; }
    $script:GetStatus = $true;

    # Connection & other checks
    try
    {
        $status = Get-Date;
        $status = " [ Status ] $NL Last Checked: $status, Internet: ";
        if((Test-Connection "1.1.1.1" -Quiet -Delay 1 -Count 1 -ErrorAction SilentlyContinue) -ieq $true)
        { $script:connec = $true; $status += "Connected.$NL" } else { $script:connec = $false; $status += "Disconnected.$NL" }
        $status +="$NL [ Settings ] 
 Authority & Mode: $script:authority
 SSL Key: $script:sslpkey
 Domain: $script:domain
 Alias(SANs): $script:alias
 $USER ID: $script:id
 Files Folder: $script:folder
$NL ";
    }
    catch
    {
        $script:connec = $false;
        $script:status = " [ Status ] $NL Error: Unknown!";
    }

    # locking <>
    $script:GetStatus = $false;

    return $status;
}

#######################################################################
function StartOver([int]$flg=0, [string]$msg="")
{
    # locking <>
    if($script:StartOver -eq $true){ return; }
    $script:StartOver = $true;

    # New Screen >>>
    Clear-Host;
    clear;
    cls;

    # Status
    $script:status = GetStatus;
    
    Write-Host $NL -NoNewline;
    Write-Host "  /                                                                        \";
    Write-Host $ZGU;
    if($script:connec -ieq $false)
    {
    Write-Host "   Hello-Free-Wild-SSL.PS1, ver 2.0.0, a utility for Let's Encrypt DV SSL.    " -ForegroundColor Black -BackgroundColor DarkGreen;
    }
    else
    {
    Write-Host "   Hello-Free-Wild-SSL.PS1, ver 2.0.0, a utility for Let's Encrypt DV SSL.    " -ForegroundColor Black -BackgroundColor Green;
    }
    Write-Host $ZGD;
    Write-Host "  \                                                                        /";
    Write-Host $NL -NoNewline;
    Write-Host $script:status;

    $thend = " The Script Ended ! ";

    if($flg -eq 1){ Write-Host " Loading... "; }
    if($flg -eq 2){ Write-Host " Starting over... "; }
    if($flg -eq 3){ Write-Host " Processing... "; }
    if($flg -eq 4){ Write-Host " Fitching... "; }
    if($flg -eq 5){ Write-Host   $thend; }

    # Wait...
    if($flg -ne 0)
    { sleep -Milliseconds $SHW; } else { sleep -Milliseconds $PRO; }

    # Show msg only after Bye !
    if($flg -eq 5 -and $msg -ne $null -and $msg -ne "")
    {
        Write-Host $RT;
        Write-Host $msg; # $BYE !
        Write-Host $RT;
    }
    else
    {
        # Connection check
        if($script:connec -ieq $false)
        {
            $MsgDebug = "Type [R] to refresh connection or any to exit script and press [Enter]...";

            # Input
            $inp = GetInput -msg $MsgDebug -style 3;

            # validate...
            if($inp -ieq "r")
            {
                # locking <>
                $script:StartOver = $false;
                # New Screen -> Blank >>>
                StartOver;
            }
            else
            {
                # Bye !
                Clear-Host;
                clear;
                cls;
                
                Write-Host $RT;
                Write-Host $thend;
                
                # wait...
                sleep -Milliseconds $SHW;
                
                Write-Host $RT;
                Write-Host $BYE;
                Write-Host $RT;
                
                exit;
            }
        }
    }
    # locking <>
    $script:StartOver = $false;
}

#######################################################################
function GoNext
{
    Param
    (
        [Parameter(Mandatory=$false, HelpMessage="title: Default = Result")]
        [string]
        $title = "Result",
        [Parameter(Mandatory=$false, HelpMessage="-msg: Your Msg...")]
        $msg = "",
        [Parameter(Mandatory=$false, HelpMessage="-exp: Default = B")]
        [string]
        $exp = "B",
        [Parameter(Mandatory=$false, HelpMessage="flg: 0 = Continue, 1 = Start, 2 = Validation, 3 = Option, 4 = Advisory, 5 = Header, 6 = Footer")]
        [int]
        $flg = 0
    );

    # locking <>
    if($script:GoNext0 -eq $true){ return; }
    $script:GoNext0 = $true;

    # User input txt
    $inp = "";

    # Msgs
    $MsgOption = "Type one of the Options Menu numbers and press [Enter]...";
    $MsgUIExp  = "Type the required text & press [Enter]...";
    $MsgNext   = "Press [Enter] to continue...";
    $MsgBack   = "Type [B] and press [Enter] to go back...";

    # Msg Flags = 6 - >>> Footer >>> Press [Enter] to continue >>>
    if($flg -eq 6)
    {
        Write-Host " $RT       << paging of function output ened >> $RT ";

        # wait...
        sleep -Milliseconds $SHW;

        # Input
        $inp = GetInput -msg $MsgNext;

        # wait...
        sleep -Milliseconds $AUT;

        # locking <>
        $script:GoNext0 = $false;

        # exit
        return;
    }

    # Msg Flags 1 -  >>> Normal >>> User text with [Enter] for Options Menu >>>
    if($flg -eq 1)
    {
        # New Screen -> Blank >>>
        StartOver;

        # Options #
        # Title
        Write-Host " [ Title ] $NL Options Menu $NL";
        # Text
        Write-Host " [ Content ] $RT";
        Write-Host "1. New/Set $USER";
        Write-Host "2. Clear Current Cached Settings";
        Write-Host "3. New/Renew SSL";
        Write-Host "4. Domain check";
        Write-Host "5. Help";
        Write-Host "6. Legal";
        Write-Host "7. Exit";

        # Input = Number
        $inp = GetInput -msg $MsgOption;
    }
    else
    {
        # loop condition
        $cnd = 1;

        # Msg Misc Flags
        while($cnd -ne 0)
        {
            # locking <>
            if($script:GoNext1 -eq $true){ continue; }
            $script:GoNext1 = $true;

            # New Screen -> Blank >>>
            StartOver;

            # Title
            Write-Host " [ Title ] $NL $title $NL";
            # Text
            Write-Host " [ Content ] $RT";
            if($msg -ne $null -and $msg -ne "")
            {
                if($msg.GetType().Name -imatch "\b(String)")
                {
                    try{ Write-Host $msg -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }catch{};
                }
                else
                {
                    try{ $msg | Format-List -Property * -Expand EnumOnly -WarningAction SilentlyContinue -ErrorAction SilentlyContinue }catch{};
                }
            }
            else
            {
                # if not Header 5 ->>>
                if($flg -ne 5){ Write-Host "A backend process has finished."; }
            }

            # Msg Flags = [ 0/null/>=size ] - >>> Normal >>> Press [Enter] to continue >>>
            if($flg -eq 0 -or $flg -eq $null -or $flg -ge 7)
            {
                # Input
                $inp = GetInput -msg $MsgNext;
                $cnd = 0;
            }

            # Msg Flags = 2 - >>> User input Required as Valid (e.g. email, domain)
            if($flg -eq 2)
            {
                # Input
                $inp = GetInput -msg $MsgUIExp -style 1;
                # validate...
                if($inp -imatch $exp){ $cnd = 0; }
            }

            # Msg Flags = 3 - >>> User input Required as Option (e.g. confirm, etc.)
            if($flg -eq 3)
            {
                # Input
                $inp = GetInput -msg $MsgUIExp -style 1;
                $cnd = 0;
            }

            # Msg Flags = 4 - >>> Advisory (e.g. Back)
            if($flg -eq 4)
            {
                # Input
                $inp = GetInput -msg $MsgBack -style 2;
                # validate...
                if($inp -ieq "b"){ $inp = "B"; $cnd = 0;}
            }

            # Msg Flags = 5 - >>> Header (e.g. Host-Out: text, print, file, etc.)
            if($flg -eq 5){ $inp = ""; $cnd = 0; }

            # locking <>
            $script:GoNext1 = $false;
        }
    }

    # locking <>
    $script:GoNext0 = $false;

    # exit
    return($inp);
}

#######################################################################
function NewSetAccount
{
    # locking <>
    if($script:NewSetAccount -eq $true){ return; }
    $script:NewSetAccount = $true;

    # Help & TOS
    $txt =
" Help:
  1. This process creates or sets the required $USER. It asks for a
     domain name(ex: example.com) not a subdomain(ex: www.example.com).
  2. During process, a preview list comes out, if any, to choose a $USER.
  3. Choose $USER or create new if there is no $USER or to solve...
  4. Issues like using old app(s) and then new app(s) with updates/drops.
  5. After choosing the required $USER, option ""New/Renew SSL"" is your next.
  6. Type [S] to strat over if such instructs you with same option number.
  7. A rare issue, may be cleaning history files.
     See: Legal -> Extra...Links -> Posh...Save-To...Folder
 
 TOS:
  Make sure you've read and agreed to option Legal before this step!
";

    # Next >>>
    GoNext -title "New/Set $USER -> Help & TOS" -msg $txt;

    # Authority & Mode
    if(-not $script:authority -or $modes -ieq "ZEROSSL_PROD")
    {
        # Input = server
        $authorities = "1. Let's Encrypt Staging *", "2. Let's Encrypt Production *", "3. Buypass.com Testing **", "4. Buypass.com Production **", "5. ZeroSSL.com Production ***";
        $modes = "LE_STAGE", "LE_PROD", "BUYPASS_TEST", "BUYPASS_PROD", "ZEROSSL_PROD";
        $txt = " - Type the option number and press [Enter]...";
        $txt+= "$NL ";
        $txt+= $authorities -join $NL+" ";
        $txt+=
        "
 __________________________________________________________________
 *   This means wild domain validation(DV) SSL and no email.
 **  This means simple domain SSL(up to 5 subdomains) and...
 **  this script only sets the default(www) and if contact...
 **  is required, sets the default(webmaster@the_domain_you_> Type).
 *** This means same as 3-4 but with external credentials requirements.
        ";

        # Next >>>
        $ret = GoNext -title "New/Set $USER -> Authority & Mode" -msg $txt -exp "^[1-5]{1}$" -flg 2;
        $ret = $ret-1;
        
        # Settings
        $script:authority = $authorities[$ret] -ireplace  "\*","";
        $script:modes = $modes[$ret];
        $script:sslpkey = $SSLPKNEW;
        if($ret -eq 0 -or $ret -eq 2){ $script:sslpkey = $SSLPKSAME; }

        # ZeroSSL
        if($ret -eq 4)
        {
            # Next - Header >>>
            GoNext -title "New/Set $USER -> Authority & Mode -> Visiting ZeroSSL" -flg 5;

                # verbose that SSL is not here
                Write-Host "Visiting ZeroSSL page ?";
                
                # Hold action for a while waiting for User action
                $ret = Read-Host $AFF;

                # check User action
                if($ret -ieq "v")
                {
                    # Check current domain yourself
                    Start-Process -FilePath "https://zerossl.com?fpr=ulike123";
                }

            # Next - Footer >>>
            GoNext -flg 6;

            # Next >>>
            GoNext -title "New/Set $USER -> Authority & Mode -> Result" -msg " - All, cancelled! $NL - Kindly, visit Authority page!" -flg 4;

            # locking <>
            $script:NewSetAccount = $false;

            # exit            
            return;
        }
    }

    # Domain
    if(-not $script:domain)
    {
        # Input = domain
        $txt = "^([\w-]+\.)+[\w-]{1,}$";
        # Next >>>
        $tmp = GoNext -title "New/Set $USER -> Domain" -msg "Enter a valid domain(e.g example.com)" -exp $txt -flg 2;

        # Domain
        $script:domain =  $tmp.Trim();
        $script:alias  =  ($script:domain, "www.$script:domain");
        $script:email  =  "webmaster@$script:domain";
        if($ret -eq 0 -or $ret -eq 1){ $script:alias =  ($script:domain, "*.$script:domain"); $script:email = ""; }
    }

    # Input = Confirmation
    $txt = 
"Are you sure to continue with the following main settings: $NL
    - Authority & Mode: $script:authority $NL
    - Domain: $script:domain $RT
    $MsgConfirm";

    # Next >>>
    $ret = GoNext -title "New/Set $USER -> Confirmation" -msg $txt -flg 3;

    # Connection & other checks
    try
    {
        if($ret -ieq "c")
        {
            # Next - Header >>>
            GoNext -title "New/Set $USER -> Set-PAServer" -flg 5;
            
                # Set Server
                $ret = Set-PAServer $script:modes -UseAltAccountRefresh -DisableTelemetry;

            # Next - Footer >>>
            GoNext -flg 6;

            # Next >>>
            GoNext -title "New/Set $USER -> Set-PAServer -> Result" -msg $ret;

            # Next - Header >>>
            GoNext -title "New/Set $USER -> Preview Valid $USER(s) -> Result" -flg 5;
                
                #
                # 1. List Account(s) >>>
                #
                $ret = Get-PAAccount -List -Status valid;
                $ret = $ret | Format-List -Property id,Folder -Expand EnumOnly -ErrorAction SilentlyContinue;
                
                # Paging...
                $ret | Out-Host -Paging -ErrorAction SilentlyContinue;

                # Alert!
                if($ret)
                { Write-Host " $RT       Kindly, copy a preferred ID from list for next step! $NL " -ErrorAction SilentlyContinue; }
                else
                { Write-Host " $RT       No $USER(s) found! $NL " -ErrorAction SilentlyContinue; }

            # Next - Footer >>>
            GoNext -flg 6;

            #
            # 2. Get Account >>>
            #
            if($ret)
            {
                # Input = one listed profile
                $txt = '^(\w+|[^\s\/\\\<\>\"\|\?\:\*]+)$';
                # Next >>>
                $idx = GoNext -title "New/Set $USER -> Get-PAAccount -> $USER" -msg " - Enter a valid $USER from previously listed or... $NL - zero(nonexistent) to start new and press [Enter]..." -exp $txt -flg 2;

                # Next - Header >>>
                GoNext -title "New/Set $USER -> Get-PAAccount -> $USER($idx)" -flg 5;

                    # 2. Get Account >>>
                    $ret = Get-PAAccount -ID $idx -Refresh;

                    # Paging...
                    if(-not $ret){ Write-Host " $NL Couldn't Find $USER($idx) ! $NL "; }
                    else{ Write-Host " $NL $USER($idx) has been chosen! $NL "; }

                # Next - Footer >>>
                GoNext -flg 6;

                if($ret)
                {
                    $txt = "New/Set $USER -> Get-PAAccount -> $USER($idx) -> Result";
                    # Next >>>
                    GoNext -title $txt -msg $ret;
                }
            }
            #
            # 3. New Account >>>
            #
            if(-not $ret)
            {
                # Next >>>
                $ret = GoNext -title "New/Set $USER -> Get-PAAccount -> Couldn't Find $USER(s) !" -msg " - Type [Y] to create a new $USER with new id or... $NL - or any to start over and press [Enter]..." -flg 3;
                
                # Set Server
                if($ret -ieq "y")
                {
                    # Next - Header >>>
                    GoNext -title "New/Set $USER -> New-PAAccount" -flg 5;
                    
                        # 3. New Account >>>
                        if($script:email -eq "")
                        {
                            $ret = New-PAAccount -AcceptTOS -Force;
                        }
                        else
                        {
                            $ret = New-PAAccount -Contact $script:email -AcceptTOS -Force;
                        }

                    # Next - Footer >>>
                    GoNext -flg 6;

                    # Next >>>
                    GoNext -title "New/Set $USER -> New-PAAccount -> Result" -msg $ret;
                }
                else
                {
                    # Next >>>
                    GoNext -title "New/Set $USER -> Get-PAAccount -> Result" -msg " - All, cancelled!" -flg 4;
                    
                    # locking <>
                    $script:NewSetAccount = $false;
                    return;
                }
            }
            #
            # 4. Set Account >>>
            #
            if($ret -ne $null)
            {
                    # $USER
                    $script:id = $ret[0].ID;
                $script:folder = $ret[0].Folder + "/$script:domain";
                # User account(in main folder) status
                $status = $ret[0].status.ToUpper();
                $status = $status.Trim();
                if($status -imatch "\b(VALID)")
                {
                    # Next - Header >>>
                    GoNext -title "New/Set $USER -> Set-PAAccount" -flg 5;

                        # Set Account by switching to the chosen Account ID
                        $ret = Set-PAAccount -ID $ret[0].ID -Force;

                    # Next - Footer >>>
                    GoNext -flg 6;

                    # Next >>>
                    GoNext -title "New/Set $USER -> Set-PAAccount -> Result" -msg $ret;

                    # Next >>>
                    GoNext -title "New/Set $USER -> Set-PAAccount -> Result" -msg "$USER is created/chosen successfully!" -flg 4;

                    # Next >>>
                    GoNext -title "New/Set $USER -> All Result" -msg "All done!";

                    # PASS !!!
                    $script:step = 2;
                }
                else # $USER
                {
                    $txt = " - $USER is found with the status($status). $NL $CRT";
                    # Next >>>
                    GoNext -title "New/Set $USER -> $USER(3) -> Error" -msg $txt -flg 4;

                    # Next >>>
                    $ret = GoNext -title "New/Set $USER -> $USER(4) -> Error" -msg $MsgSkipErr -flg 3;
                    
                    # Exit for ERROR
                    if($ret -ine "s"){ $script:step = 0; }
                }
            }
            else # $USER
            {
                # Next >>>
                GoNext -title "New/Set $USER -> $USER(1) -> Error" -msg " - Failed setting a $USER! $NL - You may restart setting a $USER again!" -flg 4;

                # Next >>>
                $ret = GoNext -title "New/Set $USER -> $USER(2) -> Error" -msg $MsgSkipErr -flg 3;
                
                # Exit for ERROR
                if($ret -ine "s"){ $script:step = 0; }
            }
        }
        else # Confirmation
        {
            # Next >>>
            GoNext -title "New/Set $USER -> Confirmation -> Result" -msg " - All, cancelled!" -flg 4;

            # DO NOTHING...
            # $script:step = $script:step = ini or same previous User inputs...
        }
    }
    catch # Function
    {
        # Next >>>
        GoNext -title "New/Set $USER -> Error" -msg "$MsgCheck $RT + Last Error: $RT - $NL$_ $RT - Domain: $script:domain" -flg 4;

        # Next - Confirmation >>>
        $ret = GoNext -title "New/Set $USER -> Error" -msg $MsgSkipErr -flg 3;

        # Exit for ERROR
        if($ret -ine "s"){ $script:step = -1; }
    }

    # locking <>
    $script:NewSetAccount = $false;
}


#######################################################################
function CCCSettings
{
    # locking <>
    if($script:CCCSettings -eq $true){ return; }
    $script:CCCSettings = $true;
    
    # script scope vars named after global info fields:
    $script:authority = $null;
    $script:modes     = $null;
    $script:sslpkey   = $null;
    $script:domain    = $null;
    $script:alias     = $null;
    $script:email     = $null;
    $script:id        = $null;
    $script:folder    = $null;

    # Next >>>
    GoNext -title "Clear Settings -> Result" -msg "All cleared!" -flg 4;
    
    # locking <>
    $script:CCCSettings = $false;
}

#######################################################################
function NewRenewSSL
{
    # locking <>
    if($script:NewRenewSSL -eq $true){ return; }
    $script:NewRenewSSL = $true;

    # User check
    if($script:step -ne 2)
    {
        # Next >>>
        GoNext -title "New/Renew SSL -> Settings Error" -msg $MsgOptIn -flg 4;

        # locking <>
        $script:NewRenewSSL = $false;

        # exit
        return;
    }

    # Help & TOS
    $txt =
" Help:
   1. This process creates or continues the required SSL. It uses the
      domain name(ex: example.com) and a subdomain(ex: www.example.com).
      See [ Settings ] -> Alias(SANs)...
   2. During process, options like New/Renew/Miscellaneous appears.
   3. Continue to SSL creation, if there is no SSL, or to solve...
   4. Issues like using old app(s) and then new app(s) with updates/drops.
   5. After choosing the required SSL option, TXTs authorization is required.
   6. Do the job of authorization and a press to wait for it.
   7. Some issues may come out so...
   8. Type [S] to strat over if such instructs you with same option number.
   9. A rare issue, may be cleaning history files.
      See: Legal -> Extra...Links -> Posh...Save-To...Folder
  10. Clean TXTs records then...
  11. Copy/Paste files from [ Settings ] -> Folder to your host SSL frontend.
  12. Wait 24-72 hours for SSL to propagate.
  13. ""Domain check"" option may help you both before/after ""New/Renew SSL"".
 
 TOS:
  Make sure you've read and agreed to option Legal before this step!
";

    # Next >>>
    GoNext -title "New/Set SSL -> Help & TOS" -msg $txt;

    # Connection & other checks
    try
    {
        # Get Order
        $order = $null;
        $order = Get-PAOrder -MainDomain $script:domain -Name "$script:domain" -Refresh;

        # Get renewal dt
        $renewAfter = $null;
        if($order -ne $null)
        {
            $renewAfter = $order.RenewAfter;
            if($renewAfter -ne $null)
            {
                $renewAfter = [DateTimeOffset]::Parse($renewAfter);
            }
        }

        # Get Auths
        $auths = $null;
        if($order -ne $null){ $auths = $order | Get-PAAuthorization; }

        # Get Auths Status
        $status = $null;
        if($auths -ne $null)
        {
            $status = $auths.status.ToUpper();
            $status = $status.Trim();
        }

        # Input = Confirmation
    $txt = 
"Are you sure to continue with the following main settings: $NL
    - Authority & Mode: $script:authority $NL
    - Domain: $script:domain $RT
    $MsgConfirm";

        # Result
        $OK = 0;

        #
        # 1. CHECK FOR RENEWAL and don't use -Force unless renewing a Miscellaneous case found(e.g. 30-59 days SSL, and about to be forced to renew etc.) ***
        #
        if($status -imatch "\b(VALID)" -or $renewAfter -ne $null)
        {
            # Next - Confirmation >>>
            $ret = GoNext -title "New/Renew SSL -> Renew -> Default -> Confirmation" -msg $txt -flg 3;

            # Confirmation checks
            if($ret -ieq "c")
            {
                # time to renew
                if ([DateTimeOffset]::Now -gt $renewAfter)
                {
                    # Renew Cert
                    if($script:sslpkey -ieq $SSLPKNEW)
                    {
                        # Next - Header >>>
                        GoNext -title "New/Renew SSL -> Renew -> Default" -flg 5;
                            $ret = New-PACertificate -Domain $script:alias `
                                                    -Name "$script:domain" `
                                                    -AcceptTOS `
                                                    -DirectoryUrl $script:modes `
                                                    -UseModernPfxEncryption `
                                                    -Plugin Manual, Manual `
                                                    -AlwaysNewKey;
                        # Next - Footer >>>
                        GoNext -flg 6;
                    }
                    else
                    {
                        # Next - Header >>>
                        GoNext -title "New/Renew SSL -> Renew -> Default" -flg 5;
                            $ret = New-PACertificate -Domain $script:alias `
                                                    -Name "$script:domain" `
                                                    -AcceptTOS `
                                                    -DirectoryUrl $script:modes `
                                                    -UseModernPfxEncryption `
                                                    -Plugin Manual, Manual;
                        # Next - Footer >>>
                        GoNext -flg 6;
                    }
                    # Next >>>
                    GoNext -title "New/Renew SSL -> Renew -> Default -> Result" -msg $ret;

                    # Next >>>
                    GoNext -title "New/Renew SSL -> Renew -> Default -> Result" -msg "SSL(Default) is expectedly renewed successfully!" -flg 4;

                    # PASS !!!
                    $OK = 1;
                }
                else # Misc
                {
                    # Next >>>
                    GoNext -title "New/Renew SSL -> Renew -> Miscellaneous ->" -msg " Miscellaneous(ex: SSL is valid, SSL propagates, workaround, force New/Renew SSL) found!";
                    
                    # Next - Confirmation >>>
                    $ret = GoNext -title "New/Renew SSL -> Renew -> Miscellaneous -> Confirmation" -msg $txt -flg 3;

                    # Confirmation checks
                    if($ret -ieq "c")
                    {
                        # New Cert
                        if($script:sslpkey -ieq $SSLPKNEW)
                        {
                            # Next - Header >>>
                            GoNext -title "New/Renew SSL -> Renew -> Miscellaneous ->" -flg 5;
                                $ret = New-PACertificate -Domain $script:alias `
                                                        -Name "$script:domain" `
                                                        -AcceptTOS `
                                                        -DirectoryUrl $script:modes `
                                                        -UseModernPfxEncryption `
                                                        -Plugin Manual, Manual `
                                                        -Force `
                                                        -AlwaysNewKey;
                            # Next - Footer >>>
                            GoNext -flg 6;
                        }
                        else
                        {
                            # Next - Header >>>
                            GoNext -title "New/Renew SSL -> Renew -> Miscellaneous" -flg 5;
                                $ret = New-PACertificate -Domain $script:alias `
                                                        -Name "$script:domain" `
                                                        -AcceptTOS `
                                                        -DirectoryUrl $script:modes `
                                                        -UseModernPfxEncryption `
                                                        -Plugin Manual, Manual `
                                                        -Force;
                            # Next - Footer >>>
                            GoNext -flg 6;
                        }
                        # Next >>>
                        GoNext -title "New/Renew SSL -> Renew -> Miscellaneous -> Result" -msg $ret;

                        # Next >>>
                        GoNext -title "New/Renew SSL -> Renew -> Miscellaneous -> Result" -msg "Miscellaneous issue is expectedly resolved successfully!" -flg 4;

                        # PASS !!!
                        $OK = 1;
                    }
                }
            }
        }
        #
        # 2. CHECK FOR OTHERS(e.g. null(nonexistent), pending, invalid, unknown etc.) and use -Force ***
        #
        else
        {
            # Next - Confirmation >>>
            $ret = GoNext -title "New/Renew SSL -> New -> Confirmation" -msg $txt -flg 3;

            # Confirmation checks
            if($ret -ieq "c")
            {
                # New Cert
                if($script:sslpkey -ieq $SSLPKNEW)
                {
                    # Next - Header >>>
                    GoNext -title "New/Renew SSL -> New" -flg 5;
                        $ret = New-PACertificate -Domain $script:alias `
                                                -Name "$script:domain" `
                                                -AcceptTOS `
                                                -DirectoryUrl $script:modes `
                                                -UseModernPfxEncryption `
                                                -Plugin Manual, Manual `
                                                -Force `
                                                -AlwaysNewKey;
                    # Next - Footer >>>
                    GoNext -flg 6;
                }
                else
                {
                    # Next - Header >>>
                    GoNext -title "New/Renew SSL -> New" -flg 5;
                        $ret = New-PACertificate -Domain $script:alias `
                                                -Name "$script:domain" `
                                                -AcceptTOS `
                                                -DirectoryUrl $script:modes `
                                                -UseModernPfxEncryption `
                                                -Plugin Manual, Manual `
                                                -Force;
                    # Next - Footer >>>
                    GoNext -flg 6;
                }
                # Next >>>
                GoNext -title "New/Renew SSL -> New -> Result" -msg $ret;

                # Next >>>
                GoNext -title "New/Renew SSL -> New -> Result" -msg "SSL is expectedly created successfully!" -flg 4;

                # PASS !!!
                $OK = 1;
            }
        }

        if($OK -ne 0)
        {
            # Next >>>
            GoNext -title "New/Renew SSL -> All Result" -msg "Expectedly, all done!";
        }
        else
        {
            # Next >>>
            GoNext -title "New/Renew SSL -> All Result" -msg " - All, cancelled!";
        }
    }
    catch
    {
        # Next >>>
        GoNext -title "New/Renew SSL -> Error" -msg "$MsgCheck $RT + Last Error: $RT - $NL$_ $RT - Domain: $script:domain" -flg 4;

        # Next - Confirmation >>>
        $ret = GoNext -title "New/Renew SSL -> Error" -msg $MsgSkipErr -flg 3;

        # Exit for ERROR
        if($ret -ine "s"){ $script:step = -2; }
    }

    # locking <>
    $script:NewRenewSSL = $false;
}

#######################################################################
function TestSSLConnection
{
    Param
    (
        [Parameter(Mandatory=$false, HelpMessage="URL: Default = https://example.com")]
        [string]
        $URL = "https://example.com"
    );

    # locking <>
    if($script:TestSSLConnection -eq $true){ return; }
    $script:TestSSLConnection = $true;

    try
    {
        $Response = Invoke-WebRequest -Uri $URL `
                                      -UseBasicParsing `
                                      -TimeoutSec 10 `
                                      -WarningAction SilentlyContinue `
                                      -ErrorAction SilentlyContinue;
        $StatusCode = $Response.StatusCode.ToString().Trim();
        if($StatusCode -imatch "2[0-9]{1}[0-9]{1}"){ $StatusCode = 200; }
    }
    catch{ $StatusCode = 9999; }

    # locking <>
    $script:TestSSLConnection = $false;

    return $StatusCode;
}

#######################################################################
function DomainCheck
{
    # locking <>
    if($script:DomainCheck -eq $true){ return; }
    $script:DomainCheck = $true;

    # User check
    if($script:step -ne 2)
    {
        # Next >>>
        GoNext -title "Check Domain -> Settings Error" -msg $MsgOptIn -flg 4;

        # locking <>
        $script:DomainCheck = $false;

        # exit
        return;
    }

    # Connection & other checks
    try
    {
        # Next - Header >>
        GoNext -title "Check Domain -> Waiting 10 seconds for secure connection response..." -flg 5;

        # Test
        $ret = TestSSLConnection -URL "https://$script:domain";
        if($ret -ieq "200")
        { Write-Host "Mostly, SSL is fine. No more action is required!"; }
        else
        {
            # verbose that SSL is not fine
            Write-Host "Mostly, SSL is not fine!";
            
            # Hold action for a while waiting for User action
            $ret = Read-Host $LNK;

            # check User action
            if($ret -ieq "y")
            {
                # Check current domain yourself
                Start-Process -FilePath "https://$script:domain";
            }
        }

        # Next - Footer >>>
        GoNext -flg 6;
    }
    catch
    {
        # Next >>>
        GoNext -title "Check Domain -> Error" -msg "$MsgCheck $RT + Last Error: $RT - $NL$_ $RT - Domain: $script:domain" -flg 4;

        # Next - Confirmation >>>
        $ret = GoNext -title "Check Domain -> Error" -msg $MsgSkipErr -flg 3;

        # Exit for ERROR
        if($ret -ine "s"){ $script:step = -4; }
    }
    
    # locking <>
    $script:DomainCheck = $false;
}

#######################################################################
function Help
{
    # locking <>
    if($script:Help -eq $true){ return; }
    $script:Help = $true;
    
    # Input = Back[B]
    # Help
    $txt =
" General Help:
   1. A free SSL is often limited to 90 days(a year quarter) to expire.
   2. You may force a ""New/Renew SSL"" option after 30 days of SSL issuance.
   3. During every ""New/Renew SSL"" process, a DNS TXT authorization is required.
   4. DNS TXT Keys(tokens) have to be created per each like: _acme-challenge.$script:domain
   5. DNS TXT records can be removed from domain after validation.
   6. Posh-ACME default SSL password is poshacme
   7. Posh-ACME Telemetry: No Telemetry!
   8. Newer SSL(if order is completed) drops all older SSL certs so...
   9. You're left with pasting/uploading the new SSL cert to your domain.
  10. Kindly, make sure you read and agree to the Legal option before using this script.
";

    # Next >>>
    GoNext -title "Help" -msg $txt -flg 4;
    
    # locking <>
    $script:Help = $false;
}

#######################################################################
function Legal
{
    # locking <>
    if($script:Legal -eq $true){ return; }
    $script:Legal = $true;

    # Input = Back[B]
    $txt =
"- This Script  :  Hello-Free-Wild-SSL.PS1, ver 2.0.0.
- Use          :  getting a free Let's Encrypt wild DV SSL.
- Developer    :  Al bunyan.
- Website      :  https://ulike123.com/
- Dependencies :  Posh-ACME Module.
- Credits to   :  Ryan Bolger, Posh-ACME Module Developer.
- Website      :  https://poshac.me/
- License      :  MIT License:
    
    Copyright (c) 2023 Al bunyan $RT
    Permission is hereby granted, free of charge, to any person obtaining a copy $RT
    of this software and associated documentation files (the ""Software""), to deal $RT
    in the Software without restriction, including without limitation the rights $RT
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell $RT
    copies of the Software, and to permit persons to whom the Software is $RT
    furnished to do so, subject to the following conditions: $RT
    The above copyright notice and this permission notice shall be included in all $RT
    copies or substantial portions of the Software. $RT
    THE SOFTWARE IS PROVIDED ""AS IS"", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR $RT
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, $RT
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE $RT
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER $RT
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, $RT
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE $RT
    SOFTWARE.

- Extra Security-Related Links:
    Posh-ACME $USER Security Files Save-To Default Folder:
        Windows: %LOCALAPPDATA%\Posh-ACME
        Linux: `$HOME/.config/Posh-ACME
        MacOS: `$HOME/Library/Preferences/Posh-ACME
    Report Badware to Google:
        https://safebrowsing.google.com/safebrowsing/report_badware/
    Report Unsafe Site Guest to Microsoft:
        https://www.microsoft.com/en-us/wdsi/support/report-unsafe-site-guest
";

    # Next >>>
    GoNext -title "Legal" -msg $txt -flg 4;

    # locking <>
    $script:Legal = $false;
}

#######################################################################
function ScriptCycle
{
    # locking <>
    if($script:ScriptCycle -eq $true){ return; }
    $script:ScriptCycle = $true;

    $cnd = 1;
    while($cnd -eq 1)
    {
        if($script:step -le 0)
        {
            # check zero to -negative step case:
            if($script:step -ne -4)
            {
                # Error Msg
                $txt = $CRT;
            }
            else
            {
                # Error Msg
                $txt = "Check you have installed the most recent PowerShell version and start terminal/script again!";
            }

            # Next >>>
            GoNext -title "Exit for Error -> Workaround" -msg $txt;
            break;
        }
        else
        {
            # New Screen -> Starting over >>>
            StartOver -flg 2;
            $opt = GoNext -flg 1;

            # options hooks switch
            if($opt -eq 1)
            {
                # New Screen -> Processing >>>
                StartOver -flg 3;
                NewSetAccount;
            }
            if($opt -eq 2)
            {
                # Clear Current Cached Settings -> Processing >>>
                StartOver -flg 3;
                CCCSettings;
            }
            if($opt -eq 3)
            {
                # New Screen -> Processing >>>
                StartOver -flg 3;
                NewRenewSSL;
            }
            if($opt -eq 4)
            {
                # New Screen -> Fitching >>>
                StartOver -flg 4;
                DomainCheck;
            }
            if($opt -eq 5)
            {
                # New Screen -> Fitching >>>
                StartOver -flg 4;
                Help;
            }
            if($opt -eq 6)
            {
                # New Screen -> Fitching >>>
                StartOver -flg 4;
                Legal;
            }
            if($opt -eq 7)
            {
                # New Screen -> Bye ! >>>
                StartOver -flg 5 -msg $BYE;
                # Bye !
                exit;
            }
        }
    }

    # locking <>
    $script:ScriptCycle = $false;
}

#######################################################################
function Hello-Free-Wild-SSL-PS1-By-Ulike123
{
    # New Screen -> Loading >>>
    StartOver -flg 1;

    # Init
    $ret = SetPoshACME;

    if($ret -eq 1)
    {
        ### Start Script Main Cycle >>>
        ScriptCycle;
    }
    else
    {
        $msg = "";
        if($ret -eq -1)
        {
            # Verbose
            $msg = 
"The script couldn't be loaded! $NL
- You may debug this by running PowerShell as sudo/admin or... $NL
- Rerun it by right-clicking the file: '(drive|directory|protocol)/path/file.ps1'  or...
- Type the cmdlet(as module): Hello-Free-Wild-SSL-PS1-By-Ulike123  and press [Enter]...";

            ### New Screen -> Bye ! >>>
            StartOver -flg 5 -msg $msg;
        }
        else
        {
            # Verbose
            $msg = 
"Posh-ACME Module couldn't be found! $NL
- Would you like trying installing it ? $RT
$MsgConfirm";

            # Next >>>
            $ret = GoNext -title "Dependencies -> Posh-ACME Module" -msg $msg -flg 3;

            if($ret -ieq "c")
            {
                # Init
                $ret = GetPoshACME;

                # check
                if($ret -eq $true)
                {
                    ### Start Script Main Cycle >>>
                    ScriptCycle;
                }
                else
                {
                    # Verbose
                    $msg = 
"Posh-ACME Module couldn't be installed! $NL
- You may debug this by installing it yourself as sudo/admin from... $NL
- https://poshac.me/ $NL
- and... $NL
- Rerun terminal/script again!";

                    ### New Screen -> Bye ! >>>
                    StartOver -flg 5 -msg $msg;
                }
            }
            else
            {
                ### New Screen -> Bye ! >>>
                StartOver -flg 5 -msg $BYE;
            }
        }
    }
}

### Start Script
Hello-Free-Wild-SSL-PS1-By-Ulike123;

### Hold action for a while after breaking main while cycle...
Read-Host " $RT Press [Enter] to leave... $RT ";

