# Gradle needs JAVA_HOME explicitly; mise knows where the JDK lives.
if [[ -z "$JAVA_HOME" ]] && (( $+commands[mise] )); then
  JAVA_HOME="$(mise where java 2>/dev/null)" && export JAVA_HOME || unset JAVA_HOME
fi
