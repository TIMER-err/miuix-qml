#!/usr/bin/env bash
set -euo pipefail
MIUIX_DIR="$(cd "$(dirname "$0")/.." && pwd)"
QML4J_DIR="${QML4J_DIR:-$MIUIX_DIR/../qml4j}"
mkdir -p "$MIUIX_DIR/build/classes"
mvn -q -f "$QML4J_DIR/pom.xml" -pl qml4j-demo-desktop -am install -DskipTests
mvn -q -f "$QML4J_DIR/pom.xml" -pl qml4j-demo-desktop dependency:build-classpath \
    -Dmdep.includeScope=runtime -Dmdep.outputFile="$MIUIX_DIR/build/classpath.txt"
MIUIX_CP="$QML4J_DIR/qml4j-demo-desktop/target/classes:$QML4J_DIR/qml4j-core/target/classes:$(cat "$MIUIX_DIR/build/classpath.txt")"
"${JAVA_HOME:+$JAVA_HOME/bin/}javac" --release 11 -cp "$MIUIX_CP" -d "$MIUIX_DIR/build/classes" "$MIUIX_DIR/tools/MiuixChecks.java"
"${JAVA_HOME:+$JAVA_HOME/bin/}java" -cp "$MIUIX_DIR/build/classes:$MIUIX_CP" io.github.timer_err.qml4j.demo.MiuixChecks "$MIUIX_DIR"
