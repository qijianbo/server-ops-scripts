#!/usr/bin/env php
<?php
ini_set('memory_limit','100M');
//-------------------------------------------------------------------------
// SWITCH DIRECTORY
//-------------------------------------------------------------------------

@ob_end_flush();
set_time_limit(0);
$Load = sys_getloadavg();
if ($Load[0] > 2) exit;
//-------------------------------------------------------------------------
// GLOBAL VARIABLES
//-------------------------------------------------------------------------
$Opt = GetOptions($argv);
 
$WorkDir = getcwd();

$Adds = array();
$Strips = array();
$Errors = array();

$IsTest = (isset($Opt['run']))?false:true;
$Limit = (isset($Opt['limit']) && $Opt['limit'] > 0)?$Opt['limit']:'-1';
$Count = 0;

msg("Startin Process in dir : " . $WorkDir);
if ($IsTest) msg("Testing only! please add --run for process");
msg("Please backup first",'red','while');

ProcessDir($WorkDir);

Summary();

function ProcessDir($Dir) {
    msg("  Process dir : " . $Dir,'blue');
    if ($Dh = opendir($Dir)) {
        while(($File = readdir($Dh)) !== false) {
            if ($File == '.' || $File == '..') continue;
            $Path = $Dir . '/' . $File;
            if (is_dir($Path)) {
                ProcessDir($Path);
            } else {
                ProcessFile($Path);
            }
        }
        closedir($Dh);
    }
}

function ProcessFile($File) {
    global $Adds,$Strips,$Errors,$IsTest,$Limit,$Count;
    
    $ga = 
"<script type=\"text/javascript\">
var rayliChannel = \"mini\";
var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-4984579-1'],
['_setDomainName', '.rayli.com.cn'],
['_setCustomVar', 2, 'channel', rayliChannel, 3],
['_trackPageview']);

(function() {
    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();
</script>
";

    if (! is_file($File) || ! is_readable($File)) return false;
    if (! preg_match('/\.htm(l)?$/i',$File)) return false;
    if ($Limit != -1 && (++$Count) > $Limit) exit;

    msg("    Process file ({$Count}): " . $File . "  ",'yellow','black',false);
    if (! is_writeable($File)) {
        array_push($Errors,$File . " , not writeable");
        msg("Error,not writable",'red');
        return false;
    }
    
    $Content = file_get_contents($File);
    if (preg_match('/(<script[^<]*google-analytics.com[^>]*<\/script>)/im',$Content,$Matched)) {
        $Content = str_replace($Matched[1],'',$Content);
        array_push($Strips,$File . " , size " . strlen($Matched[1]));
        msg("Striped,",'cyan','black',false);
    }
    
    if (preg_match('/<\/head>/i',$Content)) {
        $Content = preg_replace('/<\/head>/i',$ga . '</head>',$Content);
    } else if (preg_match('/<body>/i',$Content)) {
        $Content = preg_replace('/<body>/i',$ga . '</head><body>',$Content);
    } else {
        array_push($Errors,$File . " , lost head/body tag");
        msg("Error,lost head/body tag",'red');
        return false;        
    }
    
    if (! $IsTest) file_put_contents($File,$Content);

    array_push($Adds,$File);
    msg("Added",'green');
}

function Summary() {
    global $WorkDir,$Adds,$Strips,$Errors,$Limit,$Count;
    
    msg("\nTotal process file : " . $Count);

    file_put_contents($WorkDir . '/' . 'ga_tag.adds',implode("\n",$Adds));
    msg("Add tags     : " . count($Adds) . ",detail : " . $WorkDir . '/' . 'ga_tag.adds');

    file_put_contents($WorkDir . '/' . 'ga_tag.strips',implode("\n",$Strips));
    msg("Strip tags   : " . count($Strips) . ",detail : " . $WorkDir . '/' . 'ga_tag.strips');

    file_put_contents($WorkDir . '/' . 'ga_tag.errors',implode("\n",$Errors));
    msg("Found Errors : " . count($Errors) . ",detail : " . $WorkDir . '/' . 'ga_tag.errors');
    
}
// get options from args list
function getOptions($argv){
    $options = array();
    foreach ($argv as $option){
        if (substr($option,0,2) == '--'){ $option = substr($option,2);
        } elseif (substr($option,0,1) == '--'){ $option = substr($option,1);
        } else { continue;}
        $kv = split('=',$option);
        if (count($kv) > 1){
            $options[$kv[0]] = $kv[1];
        }else{
            $options[$kv[0]] = '';
        }
    }
    return($options);
}
function errorHandler($ErrorNo,$Error,$ErrorFile,$ErrorLine,$Context) {
    // 红底白字
    msg($Error,null,'red');
    exit(1);
}

function msg($Msg,$Color = null,$Bg = null,$NewLine = true,$Bold = true,$Reset = true) {
    $EscCode = "\033";
    $BoldOnCode = $EscCode . "[1m";
    $BoldOffCode = $EscCode . "[22m";
    $ResetCode = $EscCode . "[0m";
    $ColorCode = array(
        'black' => $EscCode . "[30m",
        'red'   => $EscCode . "[31m",
        'green' => $EscCode . "[32m",
        'yellow'=> $EscCode . "[33m",
        'blue'  => $EscCode . "[34m",
        'purple'=> $EscCode . "[35m",
        'cyan'  => $EscCode . "[36m",
        'white' => $EscCode . "[37m");
    $BgCode = array(
        'black' => $EscCode . "[40m",
        'red'   => $EscCode . "[41m",
        'green' => $EscCode . "[42m",
        'yellow'=> $EscCode . "[43m",
        'blue'  => $EscCode . "[44m",
        'purple'=> $EscCode . "[45m",
        'cyan'  => $EscCode . "[46m",
        'white' => $EscCode . "[47m");
    if ($Color == '' || $Color == null) $Color = 'white';
    if ($Bg == '' || $Bg == null) $Bg = 'black';
    echo $ColorCode[$Color] . $BgCode[$Bg] . (($Bold)?$BoldOnCode:'') . $Msg;
    if ($Reset) echo $ResetCode;
    if ($NewLine) echo "\n";
}
    
?>
