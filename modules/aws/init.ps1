Register-ArgumentCompleter -Native -CommandName aws -ScriptBlock {
  param($word, $ast, $cursor)
  $env:COMP_LINE = $ast.ToString(); $env:COMP_POINT = $cursor
  aws_completer.exe | ForEach-Object { [System.Management.Automation.CompletionResult]::new($_) }
  Remove-Item Env:COMP_LINE, Env:COMP_POINT
}
