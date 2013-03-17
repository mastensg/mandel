{-# LANGUAGE ForeignFunctionInterface #-}

import Data.Binary.Put
import qualified Data.ByteString.Lazy as BL
import Data.Complex
import Foreign
import Foreign.C.Types

foreign import ccall "mandelbrot.h mandelbrot"
    c_mandelbrot :: Float -> Float -> Int

type Point = Complex Float

transform :: Integer -> (Integer, Integer) -> Point
transform size (x, y) = a :+ b
  where
    a = -2 + 4 * fromInteger x / fromInteger size
    b =  2 - 4 * fromInteger y / fromInteger size

grid :: Integer -> [[Point]]
grid size = [[transform size (x, y) | x <- range] | y <- range]
  where
    range = [0 .. size - 1]

iterations :: Point -> Int
iterations p = c_mandelbrot (realPart p) (imagPart p)

mandelbrot :: Integer -> [[Int]]
mandelbrot = (map . map) iterations . grid

header :: Integer -> Put
header size = do
    putWord8    0       -- id length
    putWord8    0       -- color map type
    putWord8    2       -- image type
    putWord16le 0       -- first entry index
    putWord16le 0       -- color map length
    putWord8    0       -- color map entry size
    putWord16le 0       -- x origin
    putWord16le wSize   -- y origin
    putWord16le wSize   -- width
    putWord16le wSize   -- height
    putWord8    24      -- pixel depth
    putWord8    32      -- image descriptor
  where
    wSize = fromInteger size

pixel :: Int -> Put
pixel i = do
    putWord8 c
    putWord8 c
    putWord8 c
  where
    c = fromInteger $ 255 - 2 * toInteger i

image :: Integer -> Put
image size = do
    header size
    (mapM_ . mapM_) pixel (mandelbrot size)

main :: IO ()
main = do
    BL.putStr $ runPut $ image 1024
