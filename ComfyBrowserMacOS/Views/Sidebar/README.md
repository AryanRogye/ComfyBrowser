      Sidebar
         |                        |------------------------->SidebarClickCoordinator
         V                        |                                     ^
    SidebarView--------SidebarCollectionCoordinator-|                   |
         |                                          |                   |
         V                                          |                   |
  SidebarScrollView                                 |                   |
         |                                          |                   |
         V                                          |                   |
SidebarCollectionView<------------------------------|                   |
      |            |                                                    |
      |            |                                                    |
      |            |                                                    |
      |            V                                                    |
      |      SidebarTabItem-----SidebarRowViewModel--|                  |
      |            |                                 |                  |
      |            V                                 |                  |
      |   SidebarItemView (*reused* Tap Only)-----------------|-------------------
      |            |                                 |                  |
      |            V                                 |                  |
      |   SidebarRow (Content)<----------------------|                  |
      |                                                                 |
      |                                                                 |
      |                                                                 |
      |                                                                 |
      |                                                                 |
SidebarFolderItem------SidebarFolderRowViewModel---|                    |
      |                                            |                    |
      V                                            |                    |
SidebarItemView (*reused* Tap Only)-------------------------|--------------------|
      |                                            |
      V                                            |
SidebarFolderRow (content)<------------------------|
