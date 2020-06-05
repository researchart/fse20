import gzip
import os
import pickle
from pathlib import Path
from typing import Callable, Generic, TypeVar
import _thread

import numpy as np
import pandas as pd
from PIL import Image
from pdb import set_trace as st

__all__ = ["abspath", "ensure_dir", "IOAction", "CsvIOAction", "ImageIOAction"]


def root_dir() -> str:
    return os.path.abspath('.')
    # current_dir = Path(os.path.dirname(os.path.abspath(__file__)))
    # while True:
    #     if (current_dir / "ROOT").exists():
    #         return str(current_dir)
    #     if len(current_dir.parts) == 1:
    #         raise RuntimeError("cannot find ROOT file")
    #     current_dir = current_dir.parent


def abspath(path: str) -> str:
    if path.startswith("/"):
        return path
    else:
        return os.path.join(root_dir(), path)


def ensure_dir(path: str) -> str:
    path = os.path.abspath(path)
    if not os.path.exists(os.path.dirname(path)):
        try:
            os.makedirs(os.path.dirname(path))
        except FileExistsError:
            pass
    return path


T = TypeVar("T")


class IOAction(Generic[T]):
    def __init__(
        self,
        path: str,
        init_fn: Callable[[], T] = None,
        cache: bool = False,
        compress: bool = False,
    ):
        self.init_fn = init_fn
        self.path = abspath(path)
        self.cache = cache
        self.compress = compress

    def save(self):
        # if self.cache and os.path.exists(self.path):
        #     return
        obj = self.init_fn()
        path = ensure_dir(self.path)
        with (
            gzip.open(path, "wb", compresslevel=6)
            if self.compress
            else open(path, "wb")
        ) as file:
            pickle.dump(obj, file)

    def load(self) -> T:
        path = self.path
        with (gzip.open(path, "rb") if self.compress else open(path, "rb")) as file:
            return pickle.load(file)

    def is_saved(self) -> bool:
        return os.path.exists(self.path)


class IOObjAction(Generic[T]):
    def __init__(
        self,
        path: str,
        compress: bool = False,
    ):
        self.path = abspath(path)
        self.compress = compress

    def save(self, obj):
        # if self.cache and os.path.exists(self.path):
        #     return
        path = ensure_dir(self.path)
        with (
            gzip.open(path, "wb", compresslevel=6)
            if self.compress
            else open(path, "wb")
        ) as file:
            pickle.dump(obj, file)

    def load(self) -> T:
        path = self.path
        with (gzip.open(path, "rb") if self.compress else open(path, "rb")) as file:
            return pickle.load(file)

    def is_saved(self) -> bool:
        return os.path.exists(self.path)

class IOBatchAction(Generic[T]):
    def __init__(
        self,
        dir: str,
        root_index: int,
        compress: bool = False,
    ):
        self.dir = abspath(dir)
        self.root_index = root_index
        self.compress = compress

    def save(self, obj, batch_index):
        # if self.cache and os.path.exists(self.path):
        #     return
        path = os.path.join(
            self.dir,
            f"{self.root_index + batch_index}.pkl"
        )
        path = ensure_dir(path)
        with (
            gzip.open(path, "wb", compresslevel=6)
            if self.compress
            else open(path, "wb")
        ) as file:
            pickle.dump(obj, file)

    def load(self, batch_index) -> T:
        path = os.path.join(
            self.dir,
            f"{self.root_index + batch_index}.pkl"
        )
        with (gzip.open(path, "rb") if self.compress else open(path, "rb")) as file:
            return pickle.load(file)


class CsvIOAction(IOAction[pd.DataFrame]):
    def __init__(
        self,
        path: str,
        init_fn: Callable[[], pd.DataFrame],
        cache: bool = False,
        compress: bool = False,
    ):
        super().__init__(path, init_fn, cache, compress)

    def save(self):
        obj = self.init_fn()
        obj.to_csv(ensure_dir(self.path))

    def load(self) -> pd.DataFrame:
        return pd.read_csv(self.path)


class ImageIOAction(IOAction[np.ndarray]):
    def __init__(
        self,
        path: str,
        init_fn: Callable[[], np.ndarray],
        cache: bool = False,
        compress: bool = False,
    ):
        super().__init__(path, init_fn, cache, compress)

    def save(self):
        obj = self.init_fn()
        if obj is None:
            path = ensure_dir(self.path)
            with (
                gzip.open(path, "wb", compresslevel=6)
                if self.compress
                else open(path, "wb")
            ) as file:
                pickle.dump(obj, file)
        else:
            assert len(obj.shape)==3
            # For array of shape 3*H*W
            if obj.shape[0]==3 or obj.shape[0]==1:
                obj = obj.transpose(1,2,0)
            if obj.shape[2]==1:
                obj = obj.squeeze()
            Image.fromarray(obj).save(ensure_dir(self.path))

    def load(self) -> np.ndarray:
        try:
            return np.array(Image.open(self.path))
        except OSError:
            path = self.path
            with (gzip.open(path, "rb") if self.compress else open(path, "rb")) as file:
                obj = pickle.load(file)
                assert obj is None
                return obj

