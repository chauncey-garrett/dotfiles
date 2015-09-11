/*
 * ;
 */

var outlineView;
var scriptOutlineView;
var detailSplitView;

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * init
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

function init()
{
    // Set up listener for click on more-info properties
    var props = document.getElementById( 'properties' );
    if ( props )
        props.addEventListener( 'click', handleClickPropertyItem, false );

    // Listen for click on script summary, if any
    var scriptSummary = document.getElementById( 'script-summary' );
    if ( scriptSummary )
        scriptSummary.addEventListener( 'click', handleClickScriptSummary, false );
    var scriptXref = document.getElementById( 'script-detail-xref' );
    if ( scriptXref )
        scriptXref. addEventListener( 'click',
                                      function( event )
                                      {
                                          handleClickScriptSummary( event );
                                          event.stopPropagation();
                                      }
                                      , false );
    
    // Set up listeners for detail view nav bar
    var detailView = document.getElementById( 'detail-view' );
    if ( detailView )
    {
        var e = detailView.querySelector( '.nav-bar' );
        if ( e )
            e.addEventListener( 'click', handleClickInDetailViewNavBar, false );
    }
    
    // Construct file hierarchy outline view before showing content area
    var fileList = document.getElementById( 'file-list' );
    if ( fileList )
    {
       outlineView = new OutlineView( fileList, false );
       outlineView.openAllItems( 'is-initial-leaf' );
    }
    document.getElementById( 'content' ).style.opacity = '1';
    
    // Initialize event handler on bundle attribute elements
    if ( fileList )
    {
        var bundleAttrElements = fileList.getElementsByClassName( 'bundle-attrs' );
        for ( var i = 0 ; i < bundleAttrElements.length ; i++ )
            bundleAttrElements[ i ].addEventListener( 'click', handleClickBundleAttributes, false );
    }
}

function handleClickBundleAttributes( event )
{
    // We only want to handle clicks on the children of 'bundle-attrs' element
    // (i.e. not the container element that has the listener).
    if ( event.target == event.currentTarget )
        return;
    
    // Find the next attribute to display
    var current = event.target;
    var next = current.nextElementSibling;
    if ( next == null )
        next = current.parentNode.firstElementChild; // current was last, go back to start
    if ( next == null )
        return; // no next?
    
    // Toggle
    current.style.display = "none";
    next.style.display = "inline";
    
    // This stops the event from propagating up to the outline item or beyond
    event.stopPropagation();
}

function handleClickPropertyItem( event )
{
    var propItem = event.target;
    while ( ! propItem.classList.contains( 'has-more-info' ) )
    {
        propItem = propItem.parentElement;
        if ( ! propItem || propItem == event.currentTarget )
            return;
    }
    var infoDiv = propItem.querySelector( '.more-info' );
    if ( ! infoDiv )
        return;
    
    var cl = propItem.classList;
    if ( propItem.classList.contains( 'showing-more-info' ) )
    {
        propItem.classList.remove( 'showing-more-info' );
        infoDiv.style.maxHeight = '0';
    }
    else
    {
        propItem.classList.add( 'showing-more-info' );
        // max-height: 0 will zero out clientHeight, offsetHeight, getComputedStyle().height
        // and getBoundingClientRect(). But with "overflow: hidden", scrollHeight gives the
        // full natural height of the element, on the premise it could scroll that much!
        // We use a larger value than the actual height, so that we have room for growth if
        // the window is resized narrower. (An alternative would be to watch for the end of the
        // transition and change the max-height to auto?)
        infoDiv.style.maxHeight = ( infoDiv.scrollHeight * 2 ) + 'px';
    }
}

function handleClickInDetailViewNavBar( event )
{
    if ( event.target.classList.contains( 'left' ) )
    {
        var detailView = document.getElementById( 'detail-view' );
        if ( detailView )
            detailView.style.left = '100%';
    }
}

function handleClickScriptSummary( event )
{
    var detailView = document.getElementById( 'detail-view' );
    if ( ! detailView )
        return; // but shouldn't happen if we get here
    
    // Construct the detail split view, if we haven't yet
    if ( ! detailSplitView )
    {
        detailSplitView = new SplitView( document.getElementById( 'scripts-view' ),
                                         true, // vertical
                                         150, // min pane width
                                         0.3 // start split at 30%
                                       );
    }

    // Construct the script outline view, if we haven't yet
    if ( ! scriptOutlineView )
    {
        scriptOutlineView = new OutlineView( document.getElementById( 'scripts-list' ), true );
        scriptOutlineView.openAllItems();
        detailView.addEventListener( OutlineView.WILL_SELECT_ITEM_EVENT,
                                     function( event )
                                     {
                                        // Don't allow an empty folder item to be selected
                                        if ( event.target.classList.contains( 'icon_folder' ) )
                                           event.preventDefault();
                                     }, false );
        detailView.addEventListener( OutlineView.DID_SELECT_ITEM_EVENT, handleScriptBrowserSelectionChanged, false );
        detailView.addEventListener( OutlineView.DID_UNSELECT_ITEM_EVENT, handleScriptBrowserSelectionChanged, false );
    }
    
    detailView.style.left = '0';
}

function handleScriptBrowserSelectionChanged( event )
{
   var didSelect = ( event.type == OutlineView.DID_SELECT_ITEM_EVENT );

   // Toggle opacity of the script details per event type
   var targetScriptIdent = event.target.id;
   var scriptsDisplay = document.getElementById( 'scripts-display' );
   var scriptDetail = scriptsDisplay.querySelector( '.' + targetScriptIdent );
   if ( scriptDetail )
   {
      scriptDetail.style.opacity = ( didSelect ? '1' : '0' );
      // Make sure that the newly selected script is visible, by scrolling the header into view
      if ( didSelect )
         scriptDetail.querySelector( '.script-metadata' ).scrollIntoViewIfNeeded();
   }

   // We want the placeholder to go away on a select of a real item, and
   // come back only if an unselect is not due to another selection (without
   // that exception, the placeholder flashes in the transition)
   var placeholder = scriptsDisplay.querySelector( '.placeholder' );
   if ( placeholder )
   {
      if ( didSelect )
         placeholder.style.opacity = '0';
      else if ( ! event.detail.willSelectOtherItem )
         placeholder.style.opacity = '1';
   }
}
