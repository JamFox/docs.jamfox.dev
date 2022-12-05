---
title: "Sharing Runners To Multiple GitLab groups/projects"
---

For some Runners with specific functionality it is more cost effective to share the Runners to multiple projects as opposed to each team hosting their own Runner. But this specific functionality might need to be restricted and can not be available globally on a GitLab instance. The following will describe the process of sharing Runners to multiple projects.

## Guide To Sharing Runners

1. Create a new group for the Runner(s)

    Since any management operation to CI/CD settings (like accessing and enabling Runners) requires Maintainer level access create a new empty group with no ciritical codebases or credentials from where the Runners are shared from. This way there is no need to give Maintainer access to existing groups or projects which might contain sensitive information or critical code.

2. Create a new empty project inside the group created in the previous step

    Runners can be registered to a GitLab group, however they are not able to be shared from one group to any other groups or projects. Runners registered to a GitLab group are locked to only that group.

3. Register Runner(s) to the project created in the previous step

    Runners registered to a project (as opposed to a group) are able to be shared to other projects by members of the project that have Maintainer access.

    [GitLab documentation for registering runners](https://docs.gitlab.com/runner/register/)

4. Unlock the Runner(s) from the project

    By default, Runners are locked to the project they were registered to. However they are different from group Runners in that they can be unlocked to be shared to other projects.

    1. On the left sidebar, select **Settings > CI/CD**.
    2. Expand **Runners**
    3. Under **Available specific runners** section press the edit button on the Runner(s) that should be shared
    4. Untick the **When a runner is locked, it cannot be assigned to other projects** option

5. Add members to the group created in the first step

    Members added to the group must have Maintainer access to be able to enable the Runners in other projects.

    For adding members it is possible to leverage GitLab's [LDAP Synchronization](https://docs.gitlab.com/ee/administration/auth/ldap/ldap_synchronization.html). By creating a separate LDAP group for users that should have access to the Runners in the group's project(s) it is possible to conveniently control access to the Runners.

6. Enable the Runner(s) on other projects

    Members of the group created in the first step, who wish to use the Runner(s) in their projects, need to have Maintainer access to the group and the group they wish to enable the Runner(s) in.

    1. Navigate to the project(s) you wish to share the Runner(s) to
    2. On the left sidebar, select **Settings > CI/CD**
    3. Expand **Runners**
    4. Under **Other available runners** press **Enable for this project** on the Runner(s) you wish to enable

## Considerations

Giving Maintainer access to members of a GitLab group will give them considerable power to change things in the group and project.

Even after locking down the permissions to be as strict as possible members with Maintainer access in a group can still do the following:

- Change project name and description
- Change URLs
- Change codebase (but this should be empty anyway)
- Full control over runner settings (!)

Last point is most notable: any member could decide to remove or add Runners to the group's projects. Other members still have to explicitly enable each Runner they wish to use, but verifying which Runner(s) are maintained and recommended by the group's owners/admins inconvenient, but possible by comparing Runner IDs (to be verified if the IDs can be spoofed).

One alternative would be to reverse the access flow by using a service account as the only one which has access to the Runner(s) project and which people invite to their projects with Maintainer access so that the service account can enable the Runners for them. But this would mean that the service account will have the same amount of power on all projects it is invited to.

Even then if a Runner has been enabled in a project by a service account, anyone who has Maintainer level access to that project where the Runner is enabled can change settings of the all enabled Runners on the project, essentially giving power to break the Runner(s) for everyone.
