public class TriggerContext {
    public Boolean isBefore;
    public Boolean isInsert;
    public Boolean isUpdate;
    public List<Case> newRecords;
    public Map<Id, Case> oldMapRecords;

    public TriggerContext(Boolean isBefore, Boolean isInsert, Boolean isUpdate, List<Case> newRecords, Map<Id, Case> oldMapRecords) {
        this.isBefore = isBefore;
        this.isInsert = isInsert;
        this.isUpdate = isUpdate;
        this.newRecords = newRecords;
        this.oldMapRecords = oldMapRecords;
    }
}
