$ErrorRecord = $error[0]

$ErrorRecord | Format-List * -Force

$ErrorRecord.InvocationInfo | Format-List *

$Exception = $ErrorRecord.Exception
for ( $i = 0; $Exception; $i++, ( $Exception = $Exception.InnerException ) ) {
	"$i" * 80
	$Exception | Format-List * -Force
}