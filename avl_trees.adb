--------------------------------------------------------------------------
-- Implementation of the AVL Tree Package
-- Joe Wingbermuehle 20020411
--------------------------------------------------------------------------

with Ada.Text_IO, Ada.Integer_Text_IO;
with Ada.Unchecked_Deallocation;

package body AVL_Trees is

   procedure Delete is new Ada.Unchecked_Deallocation(Node, Node_Pointer);

   function Get_Height(root : Node_Pointer) return Natural;

   procedure Set_Balance(root : in out Node_Pointer);

   procedure Rotate_Single_Right(root : in out Node_Pointer);

   procedure Rotate_Single_Left(root : in out Node_Pointer);

   procedure Rotate_Double_Right(root : in out Node_Pointer);

   procedure Rotate_Double_Left(root : in out Node_Pointer);

   function Find_Item(tree : AVL_Tree;
                      key  : Key_Type) return Node_Pointer;

   ------------------------------------------------------------------
   -- Find an item in the tree and return a pointer to the node
   ------------------------------------------------------------------
   function Find_Item(tree : AVL_Tree;
                      key  : Key_Type) return Node_Pointer is
      np : Node_Pointer := tree.root;
   begin
      while np /= null loop
         if np.key < key then
            np := np.right;
         elsif key < np.key then
            np := np.left;
         else
            return np;
         end if;
      end loop;
      return null;
   end Find_Item;

   ------------------------------------------------------------------
   -- Find an item in the tree
   ------------------------------------------------------------------
   function Get(tree : AVL_Tree;
                key  : Key_Type) return Item_Type is
      np : constant Node_Pointer := Find_Item(tree, key);
   begin
      return np.item;
   end Get;

   ------------------------------------------------------------------
   -- Check if an item exists
   ------------------------------------------------------------------
   function Exists(tree : AVL_Tree;
                   key  : Key_Type) return Boolean is
      np : constant Node_Pointer := Find_Item(tree, key);
   begin
      return np /= null;
   end Exists;

   ------------------------------------------------------------------
   -- Insert an item to the tree
   ------------------------------------------------------------------
   procedure Insert(tree   : in out AVL_Tree;
                    key    : in Key_Type;
                    item   : in Item_Type) is

      -- Insert the item in the subtree starting at root
      procedure Insert_Helper(root : in out Node_Pointer) is
         np   : Node_Pointer;
      begin
         if root = null then
            root := new Node;
            root.key := key;
            root.item := item;
            root.left := null;
            root.right := null;
            root.balance := 0;
            return;
         end if;

         if key < root.key then
            if root.left /= null then
               Insert_Helper(root.left);
               Set_Balance(root);
               return;
            else
               root.left := new Node;
               np := root.left;
               if root.right = null then
                  root.balance := -1;
               end if;
            end if;
         else
            if root.right /= null then
               Insert_Helper(root.right);
               Set_Balance(root);
               return;
            else
               root.right := new Node;
               np := root.right;
               if root.left = null then
                  root.balance := 1;
               end if;
            end if;
         end if;
         np.key := key;
         np.item := item;
         np.left := null;
         np.right := null;
         np.balance := 0;
      end Insert_Helper;
   begin
      Insert_Helper(tree.root);
   end Insert;

   ------------------------------------------------------------------
   -- Remove an item from the tree
   ------------------------------------------------------------------
   procedure Remove(tree   : in out AVL_Tree;
                    key    : in Key_Type) is

      -- Remove an item from the tree starting at root
      procedure Remove_Helper(root  : in out Node_Pointer;
                              key   : in Key_Type) is
         np    : Node_Pointer;
         last  : Node_Pointer;
      begin
         if root = null then
            raise Not_Found;
         end if;
         if key < root.key then
            Remove_Helper(root.left, key);
            Set_Balance(root);
         elsif root.key < key then
            Remove_Helper(root.right, key);
            Set_Balance(root);
         else
            if root.right /= null then
               np := root.right;
               last := null;
               while np.left /= null loop
                  last := np;
                  np := np.left;
               end loop;
               if last /= null then
                  root.key := last.left.key;
                  root.item := last.left.item;
                  Remove_Helper(last.left, last.left.key);
               else
                  root.key := root.right.key;
                  root.item := root.right.item;
                  Remove_Helper(root.right, root.right.key);
               end if;
            elsif root.left /= null then
               np := root.left;
               last := null;
               while np.right /= null loop
                  last := np;
                  np := np.right;
               end loop;
               if last /= null then
                  root.key := last.right.key;
                  root.item := last.right.item;
                  Remove_Helper(last.right, last.right.key);
               else
                  root.key := root.left.key;
                  root.item := root.left.item;
                  Remove_Helper(root.left, root.left.key);
               end if;
            else
               Delete(root);
               root := null;
            end if;
         end if;
      end Remove_Helper;
   begin
      Remove_Helper(tree.root, key);
   end Remove;

   ------------------------------------------------------------------
   -- Get the height of the tree starting at root
   ------------------------------------------------------------------
   function Get_Height(root : Node_Pointer) return Natural is
      height   : Natural      := 0;
      temp     : Node_Pointer := root;
   begin
      while temp /= null loop
         height := height + 1;
         if temp.balance > 0 then
            temp := temp.right;
         else
            temp := temp.left;
         end if;
      end loop;
      return height;
   end Get_Height;

   ------------------------------------------------------------------
   -- Rebalance the tree starting at root
   ------------------------------------------------------------------
   procedure Set_Balance(root : in out Node_Pointer) is
      left  : constant Natural := Get_Height(root.left);
      right : constant Natural := Get_Height(root.right);
   begin
      root.balance := Balance_Type(right - left);
      if root.balance < -1 then
         if root.left.balance > 1 then
            Rotate_Double_Right(root);
         else
            Rotate_Single_Right(root);
         end if;
      elsif root.balance > 1 then
         if root.right.balance < -1 then
            Rotate_Double_Left(root);
         else
            Rotate_Single_Left(root);
         end if;
      end if;
   end Set_Balance;

   ------------------------------------------------------------------
   -- Perform a single right rotation on root
   ------------------------------------------------------------------
   procedure Rotate_Single_Right(root : in out Node_Pointer) is
      a : constant Node_Pointer := root.left.left;
      b : constant Node_Pointer := root.left.right;
      c : constant Node_Pointer := root.right;
      d : constant Node_Pointer := root.left;
      e : constant Node_Pointer := root;
   begin
      d.balance := 0;
      e.balance := 0;
      root := d;
      root.right := e;
      root.left := a;
      root.right.left := b;
      root.right.right := c;
   end Rotate_Single_Right;

   ------------------------------------------------------------------
   -- Perform a single left rotation on root
   ------------------------------------------------------------------
   procedure Rotate_Single_Left(root : in out Node_Pointer) is
      a : constant Node_Pointer := root.left;
      b : constant Node_Pointer := root.right.left;
      c : constant Node_Pointer := root.right.right;
      d : constant Node_Pointer := root;
      e : constant Node_Pointer := root.right;
   begin
      d.balance := 0;
      e.balance := 0;
      root := e;
      root.left := d;
      root.left.left := a;
      root.left.right := b;
      root.right := c;
   end Rotate_Single_Left;

   ------------------------------------------------------------------
   -- Perform a double right rotation on root
   ------------------------------------------------------------------
   procedure Rotate_Double_Right(root : in out Node_Pointer) is
   begin
      Rotate_Single_Left(root.left);
      Rotate_Single_Right(root);
   end Rotate_Double_Right;

   ------------------------------------------------------------------
   -- Perform a double left rotation on root
   ------------------------------------------------------------------
   procedure Rotate_Double_Left(root : in out Node_Pointer) is
   begin
      Rotate_Single_Right(root.right);
      Rotate_Single_Left(root);
   end Rotate_Double_Left;

   ------------------------------------------------------------------
   -- Clean up.
   ------------------------------------------------------------------
   procedure Finalize(tree : in out AVL_Tree) is

      procedure Remove_Node(node : in out Node_Pointer) is
      begin
         if node /= null then
            Remove_Node(node.left);
            Remove_Node(node.right);
            Delete(node);
         end if;
      end Remove_Node;

   begin
      Remove_Node(tree.root);
   end Finalize;

end AVL_Trees;
