/*
 * outline_view.js
 */

function OutlineView( rootElement, allowSelection )
{
   this._root = rootElement;
   this._root.classList.add( 'outline-view' );
   this._prepareTree( rootElement );

   this._allowSelection = allowSelection;
   if ( allowSelection )
   {
      ++OutlineView._canvasNum;
      this._canvasName = 'outline-bg-canvas-' + OutlineView._canvasNum;
      this._root.style.backgroundImage = '-webkit-canvas( ' + this._canvasName + ' )';
   }
   this._currentSelection = null;

   this._root.addEventListener( 'click',
                                this._handleClickEvent.bind( this ),
                                false );
}

OutlineView.WILL_SELECT_ITEM_EVENT = 'will-select-item';
OutlineView.DID_SELECT_ITEM_EVENT = 'did-select-item';
OutlineView.WILL_UNSELECT_ITEM_EVENT = 'will-unselect-item';
OutlineView.DID_UNSELECT_ITEM_EVENT = 'did-unselect-item';

// Used to generate a unique canvas name for each distinct selection-aware outline
OutlineView._canvasNum = 0;

OutlineView.prototype._prepareTree = function( tree )
{
   this._visitEachItem( tree,
                        function( elem, isLeaf )
                        {
                           var cl = elem.classList;
                           cl.add( 'outline-node' );
                           if ( isLeaf )
                              cl.add( 'outline-leaf' );
                           return true;
                        } );
}

OutlineView.prototype.openAllItems = function( pseudoLeafClass )
{
   this._visitEachItem( this._root,
                        function( elem, isLeaf )
                        {
                           if ( isLeaf )
                              return false; // we're done anyway
                           var cl = elem.classList;
                           if ( pseudoLeafClass && cl.contains( pseudoLeafClass ) )
                              return false;
                           cl.add( 'outline-open' );
                           return true;
                        } );
}

OutlineView.prototype.isItemLeaf = function( item )
{
   return item.classList.contains( 'outline-leaf' );
}

OutlineView.prototype.isItemVisible = function( item )
{
   var p = item.parentElement;
   while ( p != null && p != this._root )
   {
      if ( p.tagName == 'LI' && ! p.classList.contains( 'outline-open' ) )
         return false; // any closed item in parent chain means not visible now
      p = p.parentElement;
   }
   return true; // found only open items in parent tree up to root
}

// Invoke handler( element, isLeaf ) on each LI element representing an item in the outline,
// with isLeaf==true on the leaf LI elements (i.e. those without direct UL children).
// If the handler returns false, any child items will be skipped. If the handler returns
// true, recursion will continue up to the leaf items.
OutlineView.prototype._visitEachItem = function( elem, handler )
{
   // A supported outline view should have a strict LI->UL->LI containment
   // (since nothing can come between UL and LI anyway, and only a direct
   // UL sublist inside an LI should be treated as having outline child nodes).
   // This means we can stop recursion when we hit anything else, which also
   // allows for extra content under the leaves (even additional lists, as long
   // as they are separated by, say, a DIV).

   // If this is an LI, we need to pre-check the children to see if
   // we are a leaf node (i.e. no direct UL children) before calling handler.
   if ( elem.tagName == 'LI' )
   {
      var childLists = [];
      for ( var c = elem.firstElementChild ; c != null ; c = c.nextElementSibling )
      {
         if ( c.tagName == 'UL' )
            childLists.push( c );
      }

      // Invoke the handler, and if it wants to recurse, proceed into UL children
      if ( handler( elem, ( childLists.length == 0 ) ) )
      {
         for ( var i = 0 ; i < childLists.length ; ++i )
            this._visitEachItem( childLists[ i ], handler );
      }
   }

   // If this is a UL, recurse directly into the LI children
   else if ( elem.tagName == 'UL' )
   {
      for ( var c = elem.firstElementChild ; c != null ; c = c.nextElementSibling )
      {
         if ( c.tagName == 'LI' )
            this._visitEachItem( c, handler );
      }
   }
}

OutlineView.prototype._handleClickEvent = function( event )
{
   // We might've clicked on an element inside the LI, so find
   // the containing item if so.
   var elem = event.target;
   while ( elem != null && elem.tagName != 'LI' )
      elem = elem.parentElement;
   if ( elem == null )
      return;

   // Check to see if we clicked on leaf node
   var cl = elem.classList;
   if ( cl.contains( 'outline-leaf' ) )
   {
      if ( this._allowSelection )
         this._handleClickOnLeafItem( elem, event );
      return;
   }

   // Toggle the clicked item
   var shouldClose = cl.contains( 'outline-open' );
   if ( shouldClose )
      cl.remove( 'outline-open' );
   else
      cl.add( 'outline-open' );
   event.stopPropagation(); // consider the event consumed

   // If Option held down, toggle all child items to this new state
   if ( event.altKey )
   {
      this._visitEachItem( elem,
                           function( listElem, isLeaf )
                           {
                              if ( ! isLeaf )
                              {
                                 var cl = listElem.classList;
                                 if ( shouldClose )
                                    cl.remove( 'outline-open' );
                                 else
                                    cl.add( 'outline-open' );
                              }
                              return true;
                           } );
   }

   // Toggling will change the root (canvas) size, forcing us to redraw selections
   this._updateSelectionUI();
}

OutlineView.prototype._handleClickOnLeafItem = function( listElem, event )
{
   // Check for click on current selection
   var unselectOnly = false;
   if ( this._currentSelection == listElem )
   {
      if ( event.metaKey )
         unselectOnly = true;
      else
         return; // without Cmd down, this is a no-op
   }

   // Fire the will events before changing anything, since we don't want to unselect the
   // current item if the new item is not allowed to be selected
   if ( this._currentSelection != null )
   {
      var willEvent = new CustomEvent( OutlineView.WILL_UNSELECT_ITEM_EVENT, { bubbles: true, cancelable: true } );
      if ( ! this._currentSelection.dispatchEvent( willEvent ) )
         return; // preventDefault() invoked by listener
   }
   if ( ! unselectOnly )
   {
      var willEvent = new CustomEvent( OutlineView.WILL_SELECT_ITEM_EVENT, { bubbles: true, cancelable: true } );
      if ( ! listElem.dispatchEvent( willEvent ) )
         return; // preventDefault() invoked by listener
   }

   // Deselect any existing selection
   if ( this._currentSelection != null )
   {
      this._currentSelection.classList.remove( 'outline-selection' );
      var eventDetail = { willSelectOtherItem: ( ! unselectOnly ) };
      var event = new CustomEvent( OutlineView.DID_UNSELECT_ITEM_EVENT, { bubbles: true, detail: eventDetail } );
      this._currentSelection.dispatchEvent( event );
      this._currentSelection = null;
   }

   // Select new item (unless we were only deselecting the current)
   if ( ! unselectOnly )
   {
      this._currentSelection = listElem;
      this._currentSelection.classList.add( 'outline-selection' );
      var event = new CustomEvent( OutlineView.DID_SELECT_ITEM_EVENT, { bubbles: true } );
      this._currentSelection.dispatchEvent( event );
   }

   // Redraw the selection on the (root) canvas
   this._updateSelectionUI();

   // Consider event consumed
   event.stopPropagation();
}

// (Re)draw the selection on the root canvas
OutlineView.prototype._updateSelectionUI = function()
{
   if ( ! this._canvasName )
      return;

   // Note that offsetWidth and offsetHeight include the border, if any, which would
   // result in passing a 2px-too-large rectangle into the canvas context, which results
   // in strange and inconsistent anti-aliasing artifacts. By using clientWidth and
   // clientHeight, we explicitly get the content+padding, but no border.
   var backingScale = window.devicePixelRatio; // e.g. 1 (non-Retina) or 2 (Retina)
   var canvasWidth = this._root.clientWidth * backingScale; // See HTML5 Canvas Guide
   var canvasHeight = this._root.clientHeight * backingScale;

   // <https://www.webkit.org/blog/176/css-canvas-drawing/>
   var ctx = document.getCSSCanvasContext( '2d', this._canvasName, canvasWidth, canvasHeight );
   if ( ! ctx )
      return;

   // Clear everything previous
   ctx.clearRect( 0, 0, canvasWidth, canvasHeight );

   // No current selection? Just leave it cleared
   if ( this._currentSelection == null )
      return;
 
   // Selected item not visible? Draw nothing else
   if ( ! this.isItemVisible( this._currentSelection ) )
      return;

   // Figure out where selection rectangle should be. For the height, we actually want the
   // line-height of the item, so that we're highlighting only the first line of that item,
   // whether or not it has children of any kind. But window.getComputedStyle().lineHeight
   // sometimes returns a pixel value, and sometimes returns "normal", and the latter does
   // us no good. Since we don't allow selection of non-leaf items anyway, give up and use
   // the height of the first client rect of the item (which would include child elements
   // if they were allowed in this context, but they are not).
   // Also, note that "offsetParent returns a reference to the object which is the closest
   // (nearest in the containment hierarchy) positioned containing element" -- so, if our root
   // element is positioned, it will be the offsetParent and the current selection's offsetTop
   // is usable as is. But otherwise, the root and the current selection should share the
   // offsetParent, so we have to use the difference instead.
   var selectionY = this._currentSelection.offsetTop;
   if ( this._currentSelection.offsetParent == this._root.offsetParent )
      selectionY -= this._root.offsetTop;
   else if ( this._currentSelection.offsetParent != this._root )
      console.log( "Unexpected offsetParent for root versus currentSelection" );
   var clientRects = this._currentSelection.getClientRects();
   if ( clientRects.length == 0 )
      return; // but should not happen
   var selectionHeight = clientRects.item( 0 ).height;

   // Per HTML5 Canvas Guide, need to draw everything at backingScale
   selectionY *= backingScale;
   selectionHeight *= backingScale;
   selectionY -= 0.5; // draw between grid to (somewhat!) avoid anti-aliasing fuzziness

   // Draw gradient fill
   var gradient = ctx.createLinearGradient( 0, selectionY, 0, selectionY + selectionHeight );
   gradient.addColorStop( 0, '#73b8ea' );
   gradient.addColorStop( 1, '#3984d2' );
   ctx.fillStyle = gradient;
   ctx.fillRect( 0, selectionY, canvasWidth, selectionHeight );

   // Draw top and bottom lines
   ctx.strokeStyle = '#5ea3df';
   ctx.lineWidth = 1;
   ctx.beginPath();
   ctx.moveTo( 0, selectionY );
   ctx.lineTo( canvasWidth, selectionY );
   ctx.stroke();
   ctx.strokeStyle = '#3577c2';
   ctx.beginPath();
   ctx.moveTo( 0, selectionY + selectionHeight );
   ctx.lineTo( canvasWidth, selectionY + selectionHeight );
   ctx.stroke();
}

