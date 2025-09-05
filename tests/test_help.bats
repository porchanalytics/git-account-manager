#!/usr/bin/env bats

# Test help system

load test_helper

@test "git-help command exists" {
  run command -v git-help
  [ "$status" -eq 0 ]
}

@test "git-help shows main help" {
  run git-help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Git Account Manager" ]]
  [[ "$output" =~ "use-personal" ]]
  [[ "$output" =~ "use-business" ]]
}

@test "git-help examples shows example workflows" {
  run git-help examples
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Examples" ]] || [[ "$output" =~ "Repository Operations" ]]
}

@test "git-help troubleshoot shows troubleshooting info" {
  run git-help troubleshoot
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Problem" ]] || [[ "$output" =~ "SSH" ]]
}

@test "git-help setup shows setup information" {
  run git-help setup
  [ "$status" -eq 0 ]
  [[ "$output" =~ "setup" ]] || [[ "$output" =~ "config" ]]
}

@test "git-help workflows shows workflow information" {
  run git-help workflows
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Workflow" ]] || [[ "$output" =~ "Scenario" ]]
}

@test "git-usage shows usage information" {
  run git-usage
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Examples" ]] || [[ "$output" =~ "Switch Identity" ]]
}