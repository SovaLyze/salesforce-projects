public with sharing class TaskController {

    @AuraEnabled(cacheable = true)
    public static List<TaskWrapper> getTasksWithRelatedInfo() {

        List<TaskWrapper> taskWrappers = new List<TaskWrapper>();

        List<Task> tasks = [
            SELECT Id, Subject, WhoId, Who.Type, Who.Name, WhatId, What.Type, What.Name
            FROM Task
            WHERE WhoId != null OR WhatId != null
        ];

        for (Task task : tasks) {
            taskWrappers.add(new TaskWrapper(task.Id, task.Subject, task.Who.Name, task.Who.Type, task.What.Name, task.What.Type));
        }

        return taskWrappers;
    }


    public class TaskWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String subject;
        @AuraEnabled public String whoName;
        @AuraEnabled public String whoType;
        @AuraEnabled public String whatName;
        @AuraEnabled public String whatType;

        public TaskWrapper(String id, String subject, String whoName, String whoType, String whatName, String whatType) {
            this.id = id;
            this.subject = subject;
            this.whoName = whoName;
            this.whoType = whoType;
            this.whatName = whatName;
            this.whatType = whatType;
        }
    }
}