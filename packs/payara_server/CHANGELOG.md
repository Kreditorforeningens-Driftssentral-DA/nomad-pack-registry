# CHANGELOG

## v0.1.1 (7. December, 2025)
#### CHANGES
  * Added optional dns-config for job-group

## v0.1.0 (5. June, 2024)
#### CHANGES
  * Allow custom of restart-configuration (group)
  * Updated vars.nomad example to include memory_max & cpu_strict
  * Fixed memory_max. Wrong order casued OOM on soft-limit.
  * Fixed cpu_strict. Wrong parameter in task-template
  * Cleanup services
  * New variables added for helper-tasks
  * Create vars.nomad with example variables (all)
  * Fixed bugs

## v0.0.3 (May 9, 2022)
#### CHANGES
  * Tweaks & fixes after test-deployments.

## v0.0.1 (May 2, 2022)
#### CHANGES
  * Added metadata for forcing redeploy
  * Added support for artifact download(s)
  * Initial release
