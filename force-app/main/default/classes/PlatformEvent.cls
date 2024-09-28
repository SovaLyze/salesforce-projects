public with sharing class PlatformEvent {

    public class PlatformEventException extends Exception {}

    public static Database.SaveResult publishEvent(Event_Recipes_Demo__e event) {
        return EventBus.publish(event);
    }

    public static Database.SaveResult publishEventWithCallbacks(Event_Recipes_Demo__e event) {
        if (event.EventUuid == null) {
            throw new PlatformEventException(
                'EventUuid is required when using a publish callback with event correlation. Create the event via sObjectType.newSObject.'
            );
        }

        PlatformEventPublishCallback.EventInfo eventInfo = new PlatformEventPublishCallback.EventInfo(
                event.EventUuid,
                event.AccountId__c
            );
            PlatformEventPublishCallback callback = new PlatformEventPublishCallback(
                new List<PlatformEventPublishCallback.EventInfo>{ eventInfo }
            );
            return EventBus.publish(event, callback);
    }
}