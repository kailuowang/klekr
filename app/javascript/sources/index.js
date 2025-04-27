/**
 * Sources Module
 * Handles source management, importing, and displaying sources
 */

// Import all source components
import Source from './source.js';
import SourceCell from './sourceCell.js';
import SourcesGridview from './sourcesGridview.js';
import StreamImporterBase from './streamImporterBase.js';
import FlexibleStreamsImporterBase from './flexibleStreamsImporterBase.js';
import AddByUserImporter from './addByUserImporter.js';
import ContactsImporter from './contactsImporter.js';
import EditorStreamsImporter from './editorStreamsImporter.js';
import GoogleReaderImporter from './googleReaderImporter.js';
import GroupStreamsImporter from './groupStreamsImporter.js';
import MySourcesView from './mySourcesView.js';
import MySources from './mySources.js';

// Define sources namespace
window.klekr = window.klekr || {};
window.klekr.Sources = window.klekr.Sources || {};

// Export components to sources namespace
window.klekr.Sources.Source = Source;
window.klekr.Sources.SourceCell = SourceCell;
window.klekr.Sources.SourcesGridview = SourcesGridview;
window.klekr.Sources.StreamImporterBase = StreamImporterBase;
window.klekr.Sources.FlexibleStreamsImporterBase = FlexibleStreamsImporterBase;
window.klekr.Sources.AddByUserImporter = AddByUserImporter;
window.klekr.Sources.ContactsImporter = ContactsImporter;
window.klekr.Sources.EditorStreamsImporter = EditorStreamsImporter;
window.klekr.Sources.GoogleReaderImporter = GoogleReaderImporter;
window.klekr.Sources.GroupStreamsImporter = GroupStreamsImporter;
window.klekr.Sources.MySourcesView = MySourcesView;
window.klekr.Sources.MySources = MySources;

// Export named components
export {
  Source,
  SourceCell,
  SourcesGridview,
  StreamImporterBase,
  FlexibleStreamsImporterBase,
  AddByUserImporter,
  ContactsImporter,
  EditorStreamsImporter,
  GoogleReaderImporter,
  GroupStreamsImporter,
  MySourcesView,
  MySources
};