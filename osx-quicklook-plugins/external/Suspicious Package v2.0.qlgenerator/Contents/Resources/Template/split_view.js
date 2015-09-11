/*
 * split_view.js
 */

function SplitView( rootElement, splitVertical, minPaneSize, splitterGutterSize, initialSplitterAt )
{
   if ( ! splitVertical )
      throw new Error( "SplitView does not yet support horizontal split" );
   if ( ! initialSplitterAt )
      initialSplitterAt = 0.33;

   this._root = rootElement;
   this._root.classList.add( 'split-view' );
   this._splitVertical = splitVertical;
   this._root.classList.add( 'split-view-vertical' );
   this._preparePanes( rootElement );

   // Determine minimum size that either pane will be allowed to reach before stopping
   this._minPaneSize = ( minPaneSize ? minPaneSize : 150 );
    
   // Determine how much "grab sludge" is on either side of splitter
   this._splitterGutterWidth = 4;

   // Adjust to initial position
   this._adjustSplitterOffset( initialSplitterAt * rootElement.offsetWidth );
}

SplitView.DID_RESIZE_PANES = 'did-resize-panes';

SplitView.prototype._preparePanes = function( rootElem )
{
   if ( rootElem.childElementCount != 2 )
      throw new Error( "Not exactly two child elements for SplitView root" );
   var tl = rootElem.firstElementChild;
   var br = rootElem.lastElementChild;

   // Wrap each pane in our own element to isolate styling
   this._paneTL = document.createElement( 'DIV' );
   this._paneTL.classList.add( 'split-view-pane-tl' );
   this._paneTL.appendChild( tl );
   this._paneBR = document.createElement( 'DIV' );
   this._paneBR.classList.add( 'split-view-pane-br' );
   this._paneBR.appendChild( br );
   rootElem.appendChild( this._paneTL );
   rootElem.appendChild( this._paneBR );

   // Insert the splitter
   this._splitter = document.createElement( 'DIV' );
   this._splitter.classList.add( 'split-view-splitter' );
   var spline = document.createElement( 'DIV' );
   spline.classList.add( 'split-view-spline' );
   this._splitter.appendChild( spline );
   rootElem.insertBefore( this._splitter, this._paneBR );

   // Add the drag event handlers
   this._splitter.addEventListener( 'dragstart',
                                    this._handleSplitterDragStart.bind( this ),
                                    false );
   this._splitter.addEventListener( 'drag',
                                    this._handleSplitterDrag.bind( this ),
                                    false );
   this._splitter.addEventListener( 'dragend',
                                    this._handleSplitterDragEnd.bind( this ),
                                    false );

   // If we get dragover anywhere inside the split view, indicate that "drop" is accepted
   // (without which WebKit will snap the element back to where it started, visually).
   rootElem.addEventListener( 'dragover',
                              function( event )
                              {
                                 event.preventDefault();
                                 return true;
                              },
                              false );
}

SplitView.prototype._adjustSplitterOffset = function( newOffset )
{
   if ( this._splitterOffset == newOffset )
      return;

   this._splitterOffset = newOffset;
   this._paneTL.style.width = ( this._splitterOffset + this._splitterGutterWidth ) + 'px';
   this._splitter.style.left = this._splitterOffset + 'px';
   this._paneBR.style.marginLeft = ( this._splitterOffset + this._splitter.offsetWidth - this._splitterGutterWidth ) + 'px';
}

SplitView.prototype._handleSplitterDragStart = function( event )
{
   this._currentDragLastOffset = event.clientX;
   this._currentDragMinOffset = this._root.offsetLeft + this._minPaneSize;
   this._currentDragMaxOffset = this._root.offsetLeft + this._root.offsetWidth - this._minPaneSize;
   event.dataTransfer.effectAllowed = 'move';
   event.dataTransfer.dropEffect = 'move';
}

SplitView.prototype._handleSplitterDrag = function( event )
{
   // Clamp to our min and max edges
   var newOffset = event.clientX;
   if ( newOffset < this._currentDragMinOffset )
      newOffset = this._currentDragMinOffset;
   else if ( newOffset > this._currentDragMaxOffset )
      newOffset = this._currentDragMaxOffset;

   // Bail if nothing has effectively changed
   if ( newOffset == this._currentDragLastOffset )
      return;

   // Otherwise, update our splitter info so content resizes dynamically
   this._adjustSplitterOffset( this._splitterOffset + ( newOffset - this._currentDragLastOffset ) );
   this._currentDragLastOffset = newOffset;
}

SplitView.prototype._handleSplitterDragEnd = function( event )
{
   this._handleSplitterDrag( event );
   // console.log( "End drag at offset " + this._currentDragLastOffset );
   this._currentDragLastOffset = undefined;

   // Dispatch our custom did-resize event
   var evt = new CustomEvent( SplitView.DID_RESIZE_PANES, { bubbles: true, cancelable: true } );
   this._root.dispatchEvent( evt );
}

