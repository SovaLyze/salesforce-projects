public with sharing class PlatformEventPublishCallback implements EventBus.EventPublishSuccessCallback, EventBus.EventPublishFailureCallback {
    
    private Map<String, EventInfo> eventMap;

    public PlatformEventPublishCallback(List<EventInfo> eventInfos) {
        this.eventMap = new Map<String, EventInfo>();
        for(EventInfo eventInfo : eventInfos) {
            this.eventMap.put(eventInfo.EventUuid, eventInfo);
        }
    }

    public void onFailure(EventBus.FailureResult result) {
        List<String> eventUuids = result.getEventUuids();

        insertTask(eventUuids, false);
    }

    public void onSuccess(EventBus.SuccessResult result) {
        List<String> eventUuids  = result.getEventUuids();

        insertTask(eventUuids, true);
    }

    private void insertTask(List<String> eventUuids, Boolean isSuccess) {
        Set<Id> relatedAccountIds = new Set<Id>();
        for (String eventUuid : eventUuids) {
            EventInfo eventInfo = this.eventMap.get(eventUuid);
            relatedAccountIds.add(eventInfo.accountId);
        }
        Map<Id, Account> relatedAccounts = new Map<Id, Account>(
            [
                SELECT OwnerId
                FROM Account
                WHERE Id = :relatedAccountIds
                WITH SYSTEM_MODE 
            ]
        );

        List<Task> tasks = new List<Task>();
        for (String eventUuid : eventUuids) {
            EventInfo eventInfo = this.eventMap.get(eventUuid);

            Task t = new Task();

            t.WhatId = eventInfo.accountId;
            t.ActivityDate = Date.today().addDays(1);
            if (isSuccess == true) {
                t.Subject = 'Follow up on Successful event publishing.';
                t.Description = 
                    'Events published successfully. Event UUID: ' + eventUuid;
            } else {
                t.Subject = 'Follow up on event publishing failure.';
                t.Description =
                    'Events failed to publish. Event UUID: ' + eventUuid;
            }
            t.OwnerId = relatedAccounts.get(eventInfo.accountId).OwnerId;
            tasks.add(t);
        }

        insert as system tasks;
    }

    public class EventInfo {
        public String eventUuid;
        public Id accountId;

        public EventInfo(String eventUuid, Id accountId) {
            this.eventUuid = eventUuid;
            this.accountId = accountId;
        }
    }
}