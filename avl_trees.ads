--------------------------------------------------------------------------
-- Generic AVL tree package
-- Joe Wingbermuehle 20020411
--------------------------------------------------------------------------

with Ada.Finalization; use Ada.Finalization;
with Ada.Unchecked_Deallocation;

generic
   type Key_Type is private;
   type Item_Type is private;
   with function "<"(a, b : Key_Type) return Boolean is <>;
package AVL_Trees is

   type AVL_Tree is new Limited_Controlled with private;

   procedure Insert(tree   : in out AVL_Tree;
                    key    : in Key_Type;
                    item   : in Item_Type);

   procedure Remove(tree   : in out AVL_Tree;
                    key    : in Key_Type);

   function Get(tree : AVL_Tree;
                key  : Key_Type) return Item_Type;

   function Exists(tree : AVL_Tree;
                   key  : Key_Type) return Boolean;

   Not_Found : exception;

private

   type Balance_Type is new Integer;

   type Node;
   type Node_Pointer is access Node;
   type Node is record
      key      : Key_Type;
      item      : Item_Type;
      balance   : Balance_Type;
      left      : Node_Pointer;
      right      : Node_Pointer;
   end record;

   type AVL_Tree is new Limited_Controlled with record
      root : Node_Pointer := null;
   end record;

   overriding
   procedure Finalize(tree : in out AVL_Tree);

end AVL_Trees;
