        TopBar----------SearchSuggestionProvider
          |
          V
SearchSuggestionsList-----SearchSuggestionCollectionCoordinator-|
          |                                                     |
          V                                                     |
SearchSuggestionScrollView                                      |
          |                                                     |
          V                                                     |
SearchSuggestionCollectionView<---------------------------------|
          |
          V
 SearchSuggestionItem------SearchSuggestion                     |
          |                                                     |
          V                                                     |
SearchSuggestionItemView (Tap + Hover)                          |
          |                                                     |
          V                                                     |
 SearchSuggestionRow (Content)<---------------------------------|
