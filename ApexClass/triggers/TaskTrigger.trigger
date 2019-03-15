//Move the code using Force.com IDE
trigger TaskTrigger on Task (after insert, after update, before delete) {
    TaskTriggerHandler.handleAfterInsert(Trigger.new);
}