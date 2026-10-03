# Machine wipe checklist

## Getting started

### 1. Before You Begin: Preparing Your Machine

There are two main scenarios before you apply these dotfiles:

- **Scenario A: It's a completely fresh OS installation.** This means the machine has just gone through its initial setup, or it's a clean slate with no personal data, apps, or configurations yet.
- **Scenario B: It's an existing machine with current data.** This machine has been in use, and it contains apps, settings, configuration files, or personal data that you **do not want replaced or lost** by applying these dotfiles.

Regardless of your scenario, it's always a good idea to perform the following:

#### 1.1. Data Backup (Crucial for Scenario B)

If you are in **Scenario B** (an existing machine), it is **crucial to back up all your existing data** before applying these dotfiles.

Checklist:

- No repo has uncommitted changes (`git status` is clean).
- No local branches have unpushed commits.
- No repo has unpublished branches.

#### 1.2. Initial OS Setup & Updates (For Both Scenarios)

For both scenarios, complete any basic operating system setup (like the macOS Setup Assistant or initial Windows configuration) and **update your Operating System to the latest version** before proceeding. This ensures you have the latest security patches and a stable base for your new setup.

### 2. Install chezmoi & apply dotfiles

See chezmoi documentation.

### 3. Restart your machine

It's recommended to restart your machine after the previous steps.
