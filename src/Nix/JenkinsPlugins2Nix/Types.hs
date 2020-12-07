{-# language OverloadedStrings #-}
{-# language DeriveGeneric #-}
{-# LANGUAGE StrictData #-}
-- |
-- Module    : Nix.JenkinsPlugins2Nix.Types
-- Copyright : (c) 2017 Mateusz Kowalczyk
-- License   : BSD3
--
-- Types used through-out jenkinsPlugins2nix
module Nix.JenkinsPlugins2Nix.Types
  ( Config(..)
  , Manifest(..)
  , Plugin(..)
  , PluginDependency(..)
  , PluginResolution(..)
  , RequestedPlugin(..)
  , ResolutionStrategy(..)
  , PluginMeta(..)
  , Dependency(..)
  , PluginName(..)
  , Version(..)
  ) where

import qualified Crypto.Hash as Hash
import           Data.Set (Set)
import           Data.Text (Text)
import           GHC.Generics
-- aeson
import           Data.Aeson

-- | The way in which version of dependencies will be picked.
data ResolutionStrategy =
  -- | Pick the version of the dependency that the package tells us
  -- about in its manifest file. If none, latest version available is
  -- used.
  AsGiven
  -- | Always pick latest version of the dependency we're told about.
  | Latest
  deriving (Show, Eq, Ord)

-- | Program configuration
data Config = Config
  { -- | Dependency resolution strategy
    resolution_strategy :: !ResolutionStrategy
    -- | User-required plugins.
  , requested_plugins :: ![RequestedPlugin]
  } deriving (Show, Eq, Ord)

-- | Plugin that user requested on the command line.
data RequestedPlugin = RequestedPlugin
  { -- | Name of the plugin.
    requested_name :: !Text
    -- | Possibly a specified version. If version not present, latest
    -- version is downloaded then pinned.
  , requested_version :: !(Maybe Text)
  } deriving (Show, Eq, Ord)

-- | Plugin resolution. Determines optional plugins.
data PluginResolution = Mandatory | Optional
  deriving (Show, Eq, Ord)

-- | A dependency on another plugin.
data PluginDependency = PluginDependency
  { -- | Is the dependency optional?
    plugin_dependency_resolution :: !PluginResolution
    -- | Name of the dependency.
  , plugin_dependency_name :: !Text
    -- | Version of the dependency.
  , plugin_dependency_version :: !Text
  } deriving (Show, Eq, Ord)

-- | All the information we need about the plugin to generate a nix
-- expression.
data Plugin = Plugin
  { -- | Download location of the plugin.
    download_url :: !Text
    -- | Checksum.
  , sha256 :: !(Hash.Digest Hash.SHA256)
    -- | Manifest information of the plugin.
  , manifest :: !Manifest
  } deriving (Show, Eq, Ord)

-- | Plugin meta-data.
data Manifest = Manifest
  { -- | @Manifest-Version@.
    manifest_version :: !Text
    -- | @Archiver-Version@.
  , archiver_version :: !(Maybe Text)
    -- | @Created-By@.
  , created_by :: !(Maybe Text)
    -- | @Built-By@.
  , built_by :: !(Maybe Text)
    -- | @Build-Jdk@.
  , build_jdk :: !(Maybe Text)
    -- | @Extension-Name@.
  , extension_name :: !(Maybe Text)
    -- | @Specification-Title@.
  , specification_title :: !(Maybe Text)
    -- | @Implementation-Title@.
  , implementation_title :: !(Maybe Text)
    -- | @Implementation-Version@.
  , implementation_version :: !(Maybe Text)
    -- | @Group-Id@.
  , group_id :: !(Maybe Text)
    -- | @Short-Name@.
  , short_name :: !Text
    -- | @Long-Name@.
  , long_name :: !Text
    -- | @Url@.
  , url :: !Text
    -- | @Plugin-Version@.
  , plugin_version :: !Text
    -- | @Hudson-Version@.
  , hudson_version :: !(Maybe Text)
    -- | @Jenkins-Version@.
  , jenkins_version :: !(Maybe Text)
    -- | @Plugin-Dependencies@.
  , plugin_dependencies :: !(Set PluginDependency)
    -- | @Plugin-Developers@.
  , plugin_developers :: !(Set Text)
  } deriving (Show, Eq, Ord)

type Version = Text
type Url = Text
type PluginName = Text

data PluginMeta = PluginMeta
  { pluginName :: PluginName
  , pluginTitle :: Text
  , pluginVersion :: Version
  , pluginUrl :: Url
  , pluginRequiredCore :: Version
  , pluginExcerpt :: Text
  , pluginDependencies :: [Dependency]
  } deriving (Eq, Show, Generic)

instance FromJSON PluginMeta where
  parseJSON = withObject "Plugin" $ \v -> PluginMeta
    <$> v .: "name"
    <*> v .: "title"
    <*> v .: "version"
    <*> v .: "url"
    <*> v .: "requiredCore"
    <*> v .: "excerpt"
    <*> v .: "dependencies"

data Dependency = Dependency
  { depName :: PluginName
  , depTitle :: Text
  , depOptional :: Bool
  , depVersion :: Version
  , depImplied :: Bool
  } deriving (Eq, Show, Generic)

instance FromJSON Dependency where
  parseJSON = withObject "Dependency" $ \v -> Dependency
    <$> v .: "name"
    <*> v .: "title"
    <*> v .: "optional"
    <*> v .: "version"
    <*> v .: "implied"
