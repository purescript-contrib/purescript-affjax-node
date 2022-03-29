module Affjax.Driver.Node
  ( request
  , get
  , post
  , post_
  , put
  , put_
  , delete
  , delete_
  , patch
  , patch_
  ) where

import Prelude

import Affjax (URL, Error(..), defaultRequest, Request, Response)
import Affjax.Driver as AD
import Affjax.Driver (AffjaxDriver)
import Affjax.RequestBody as RequestBody
import Affjax.RequestHeader (RequestHeader(..))
import Affjax.RequestHeader as RequestHeader
import Affjax.ResponseFormat as ResponseFormat
import Affjax.ResponseHeader (ResponseHeader(..))
import Control.Alt ((<|>))
import Control.Monad.Except (runExcept)
import Data.Argonaut.Core (Json)
import Data.Argonaut.Core as J
import Data.Argonaut.Parser (jsonParser)
import Data.Array as Arr
import Data.ArrayBuffer.Types (ArrayView)
import Data.Either (Either(..), either, note)
import Data.Foldable (any)
import Data.FormURLEncoded as FormURLEncoded
import Data.Function (on)
import Data.Function.Uncurried (Fn2, Fn5, runFn5)
import Data.HTTP.Method (Method(..))
import Data.HTTP.Method as Method
import Data.List.NonEmpty as NEL
import Data.Maybe (Maybe(..), fromMaybe)
import Data.Nullable (Nullable, toNullable)
import Data.Time.Duration (Milliseconds(..))
import Effect.Aff (Aff, try)
import Effect.Aff.Compat as AC
import Effect.Exception as Exn
import Foreign (F, Foreign, ForeignError(..), fail, unsafeReadTagged, unsafeToForeign)
import Web.DOM (Document)
import Web.File.Blob (Blob)
import Web.XHR.FormData (FormData)

foreign import nodeDriver :: AffjaxDriver

-- | Makes a `GET` request to the specified URL.
get :: forall a. ResponseFormat.ResponseFormat a -> URL -> Aff (Either Error (Response a))
get = AD.get nodeDriver

-- | Makes a `POST` request to the specified URL with the option to send data.
post :: forall a. AffjaxDriver -> ResponseFormat.ResponseFormat a -> URL -> Maybe RequestBody.RequestBody -> Aff (Either Error (Response a))
post = AD.post nodeDriver

-- | Makes a `POST` request to the specified URL with the option to send data
-- | and ignores the response body.
post_ :: AffjaxDriver -> URL -> Maybe RequestBody.RequestBody -> Aff (Either Error Unit)
post_ = AD.post_ nodeDriver

-- | Makes a `PUT` request to the specified URL with the option to send data.
put :: forall a. AffjaxDriver -> ResponseFormat.ResponseFormat a -> URL -> Maybe RequestBody.RequestBody -> Aff (Either Error (Response a))
put = AD.put nodeDriver

-- | Makes a `PUT` request to the specified URL with the option to send data
-- | and ignores the response body.
put_ :: AffjaxDriver -> URL -> Maybe RequestBody.RequestBody -> Aff (Either Error Unit)
put_ = AD.put_ nodeDriver

-- | Makes a `DELETE` request to the specified URL.
delete :: forall a. AffjaxDriver -> ResponseFormat.ResponseFormat a -> URL -> Aff (Either Error (Response a))
delete = AD.delete nodeDriver

-- | Makes a `DELETE` request to the specified URL and ignores the response
-- | body.
delete_ :: AffjaxDriver -> URL -> Aff (Either Error Unit)
delete_ = AD.delete_ nodeDriver

-- | Makes a `PATCH` request to the specified URL with the option to send data.
patch :: forall a. AffjaxDriver -> ResponseFormat.ResponseFormat a -> URL -> RequestBody.RequestBody -> Aff (Either Error (Response a))
patch = AD.patch nodeDriver

-- | Makes a `PATCH` request to the specified URL with the option to send data
-- | and ignores the response body.
patch_ :: AffjaxDriver -> URL -> RequestBody.RequestBody -> Aff (Either Error Unit)
patch_ = AD.patch_ nodeDriver

-- | Makes an HTTP request.
-- |
-- | The example below performs a `GET` request to the URL `/resource` and
-- | interprets the response body as JSON.
-- |
-- | ```purescript
-- | import Affjax.ResponseFormat (json)
-- | ...
-- | request (defaultRequest { url = "/resource", method = Left GET, responseFormat = json})
-- | ```
-- |
-- | For common cases helper functions can often be used instead of `request` .
-- | For instance, the above example is equivalent to the following.
-- |
-- | ```purescript
-- | get json "/resource"
-- | ```
request :: forall a. AffjaxDriver -> Request a -> Aff (Either Error (Response a))
request = AD.request nodeDriver
