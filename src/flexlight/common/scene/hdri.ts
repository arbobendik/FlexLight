// Credit to https://github.com/DerSchmale/io-rgbe for the implementation that was used to create this file

interface HDRImageData {
	width: number;
	height: number;
	exposure: number;
	gamma: number;
	data: Float32Array;
}

type Header = {
	width: number,
	height: number,
	gamma: number,
	exposure: number,
	colorCorr: number[],
	flipX: boolean,
	flipY: boolean
};

type DataStream = {
	offset: number,
	data: DataView
};

// Decodes RGBE-encoded data to a flat list of floating point pixel data (RGB).
export function decodeRGBE(data: DataView): HDRImageData {
	const stream = {
		data,
		offset: 0
	};

	const header = parseHeader(stream);

	return {
		width: header.width,
		height: header.height,
		exposure: header.exposure,
		gamma: header.gamma,
		data: parseData(stream, header)
	};
}

function parseHeader(stream: DataStream): Header {
	let line = readLine(stream);
	const header = {
		colorCorr: [ 1, 1, 1 ],
		exposure: 1,
		gamma: 1,
		width: 0,
		height: 0,
		flipX: false,
		flipY: false
	};

	if (line !== "#?RADIANCE" && line !== "#?RGBE")
		throw new Error("Incorrect file format!");

	while (line !== "") {
		// empty line means there's only 1 line left, containing size info:
		line = readLine(stream);
		const parts = line.split("=");
		switch (parts[0]) {
			case "GAMMA":
				header.gamma = parseFloat(parts[1]!);
				break;
			case "FORMAT":
				if (parts[1] !== "32-bit_rle_rgbe" && parts[1] !== "32-bit_rle_xyze")
					throw new Error("Incorrect encoding format!");
				break;
			case "EXPOSURE":
				header.exposure = parseFloat(parts[1]!);
				break;
			case "COLORCORR":
				header.colorCorr = parts[1]!.replace(/^\s+|\s+$/g, "").split(" ").map(m => parseFloat(m));
				break;
		}
	}

	line = readLine(stream);

	const parts = line.split(" ");
	parseSize(parts[0]!, parseInt(parts[1]!), header);
	parseSize(parts[2]!, parseInt(parts[3]!), header);

	return header;
}

function parseSize(label: string, value: number, header: Header) {
	switch (label) {
		case "+X":
			header.width = value;
			break;
		case "-X":
			header.width = value;
			header.flipX = true;
			console.warn("Flipping horizontal orientation not currently supported");
			break;
		case "-Y":
			header.height = value;
			break;
		case "+Y":
			header.height = value;
			header.flipY = true;
			break;
	}
}

function readLine(stream: DataStream): string {
	let ch, str = "";
	while ((ch = stream.data.getUint8(stream.offset++)) !== 0x0a) str += String.fromCharCode(ch);
	return str;
}

function parseData(stream: DataStream, header: Header): Float32Array {
	let hash = stream.data.getUint16(stream.offset);
	let data;

	if (hash === 0x0202) {
		data = parseNewRLE(stream, header);
		if (header.flipX) flipX(data, header);
		if (header.flipY) flipY(data, header);
	}
	else {
		throw new Error("Obsolete HDR file version!");
	}

	return data;
}

function parseNewRLE(stream: DataStream, header: Header): Float32Array {
	const { width, height, colorCorr } = header;
	const tgt = new Float32Array(width * height * 3);
	let i = 0;
	let { offset, data } = stream;

	for (let y = 0; y < height; ++y) {
		if (data.getUint16(offset) !== 0x0202)
			throw new Error("Incorrect scanline start hash");

		if (data.getUint16(offset + 2) !== width)
			throw new Error("Scanline doesn't match picture dimension!");

		offset += 4;
		const numComps = width * 4;

		// read individual RLE components
		const comps = [];
		let x = 0;

		while (x < numComps) {
			let value = data.getUint8(offset++);
			if (value > 128) {
				// RLE:
				const len = value - 128;
				value = data.getUint8(offset++);
				for (let rle = 0; rle < len; ++rle) {
					comps[x++] = value;
				}
			}
			else {
				for (let n = 0; n < value; ++n) {
					comps[x++] = data.getUint8(offset++);
				}
			}
		}

		for (x = 0; x < width; ++x) {
			const r = comps[x]!;
			const g = comps[x + width]!;
			const b = comps[x + width * 2]!;
			let e = comps[x + width * 3]!;

			// NOT -128 but -136!!! This allows encoding smaller values rather than higher ones (as you'd expect).
			e = e ? Math.pow(2.0, e - 136) : 0;

			tgt[i++] = r * e * colorCorr[0]!;
			tgt[i++] = g * e * colorCorr[1]!;
			tgt[i++] = b * e * colorCorr[2]!;
		}
	}

	return tgt;
}

function swap(data: Float32Array, i1: number, i2: number) {
	i1 *= 3;
	i2 *= 3;

	for (let i = 0; i < 3; ++i) {
		const tmp = data[i1 + i]!;
		data[i1 + i] = data[i2 + i]!;
		data[i2 + i] = tmp;
	}
}

function flipX(data: Float32Array, header: Header) {
	const { width, height } = header;
	const hw = width >> 1;

	for (let y = 0; y < height; ++y) {
		// selects the current row
		const b = y * width;
		for (let x = 0; x < hw; ++x) {
			// add the mirrored columns
			const i1 = b + x;
			const i2 = b + width - 1 - x;
			swap(data, i1, i2);
		}
	}
}

function flipY(data: Float32Array, header: Header) {
	const { width, height } = header;
	const hh = height >> 1;

	for (let y = 0; y < hh; ++y) {
		// selects the mirrored rows
		const b1 = y * width;
		const b2 = (height - 1 - y) * width;

		for (let x = 0; x < width; ++x) {
			// adds the column
			swap(data, b1 + x, b2 + x);
		}
	}
}