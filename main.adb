
with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
with Ada.Calendar; use Ada.Calendar;

with AVL_Trees;

--------------------------------------------------------------------------
-- Test Driver for the AVL Tree package
--------------------------------------------------------------------------
procedure Main is

   lower   : constant Integer := 1;
   upper   : constant Integer := 100000;

   subtype Key_Type is Integer range lower .. upper;

   type Value_Node is record
      value : Integer;
   end record;

   package Int_Trees is new AVL_Trees(Key_Type, Value_Node);

   package Int_Random is new Ada.Numerics.Discrete_Random(Key_Type);

   tree : Int_Trees.AVL_Tree;

   seed        : Int_Random.Generator;
   errors      : Integer := 0;
   start       : Time;
   stop        : Time;
   total       : Duration;
   temp        : Integer;

   ------------------------------------------------------------------
   -- Create a Value_Node record from an integer
   ------------------------------------------------------------------
   function To_Value_Node(a : Integer) return Value_Node is
      result      : Value_Node;
   begin
      result.value := a;
      return result;
   end To_Value_Node;

   ------------------------------------------------------------------
   -- Fill the AVL tree with numbers in random order
   ------------------------------------------------------------------
   procedure Fill_Random is
      temp   : Key_Type;
   begin
      Put("Inserting...");
      start := Clock;
      for x in lower .. upper loop
         loop
            temp := Int_Random.Random(seed);
            exit when not tree.Exists(temp);
         end loop;
         tree.Insert(temp, To_Value_Node(temp));
      end loop;
      stop := Clock;
      total := stop - start;
      Put_Line("done (" & Duration'Image(total) & " seconds)");
   end Fill_Random;

   ------------------------------------------------------------------
   -- Try to remove an item, add to errors on error
   ------------------------------------------------------------------
   procedure Try_Remove(x : Key_Type) is
   begin
      tree.Remove(x);
   exception
      when Int_Trees.Not_Found =>
         errors := errors + 1;
         Put_Line("ERROR removing " & Key_Type'Image(x));
   end Try_Remove;

begin

   Put_Line("Test the AVL Tree package with" &
            Integer'Image(upper) & " elements");

   Fill_Random;
   Put("Search...");
   start := Clock;
   for x in lower .. upper loop
      temp := tree.Get(x).value;
      if temp /= x then
         errors := errors + 1;
         Put_Line("ERROR finding " & Integer'Image(x));
      end if;
   end loop;
   stop := Clock;
   total := stop - start;
   Put_Line("done (" & Duration'Image(total) & " seconds)");
   Put("Removing...");
   start := Clock;
   for x in lower .. upper loop
      Try_Remove(x);
   end loop;
   stop := Clock;
   total := stop - start;
   Put_Line("done (" & Duration'Image(total) & " seconds)");

   Fill_Random;
   Put("Removing (in reverse)...");
   start := Clock;
   for x in reverse lower .. upper loop
      Try_Remove(x);
   end loop;
   stop := Clock;
   total := stop - start;
   Put_Line("done (" & Duration'Image(total) & " seconds)");

   Put_Line(Integer'Image(errors) & " errors found");

end Main;

