with Ada.Text_IO, GNAT.Semaphores;
use Ada.Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

procedure Consumer_Producer is
   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter (Storage_Size : in Integer; Item_Numbers : in Integer) is
      Storage : List;
      Full   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty  : Counting_Semaphore (0, Default_Ceiling);
      Access_Storage : Counting_Semaphore (1, Default_Ceiling);

      task type Consumer is
         entry Start(Item_Numbers:Integer);
      end;

      task type Producer is
         entry Start(Item_Numbers:Integer);
      end;


      task body Consumer is
         Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Consumer.Item_Numbers := Item_Numbers;
           end Start;

         for i in 1 .. Item_Numbers loop
            Empty.Seize;
            Access_Storage.Seize;

            declare
               item : String := First_Element (Storage);
            begin
               Put_Line ("Took " & item);
            end;

            Storage.Delete_First;

            Access_Storage.Release;
            Full.Release;

            delay 0.3;
         end loop;

      end Consumer;

      task body Producer is
           Item_Numbers : Integer;
      begin
           accept Start (Item_Numbers : in Integer) do
              Producer.Item_Numbers := Item_Numbers;
           end Start;

         for i in 1 .. Item_Numbers loop
            Full.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & i'Img);
            Put_Line ("Added item " & i'Img);

            Access_Storage.Release;
            Empty.Release;
            delay 0.1;
         end loop;

      end Producer;

      Consumers : array (1..3) of Consumer;
      Producers :array (1..3) of Producer;
      Items_to_add:array(1..3) of Integer:=(3,7,10);
   begin
      for i in  Consumers'Range loop
         Consumers(i).Start(Items_to_add(i));
         Producers(i).Start(Items_to_add(i));
      end loop;
   end Starter;

begin
   Starter (6, 24);
end Consumer_Producer;
